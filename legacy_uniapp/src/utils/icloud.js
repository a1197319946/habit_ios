/**
 * iCloud Sync Utility for iOS App
 * Uses Native.js to access iCloud Ubiquity Container
 */

export function checkiCloudStatus() {
  // #ifdef APP-PLUS
  if (plus.os.name !== 'iOS') return false;
  try {
    var NSFileManager = plus.ios.importClass("NSFileManager");
    var defaultManager = NSFileManager.defaultManager();
    var token = defaultManager.ubiquityIdentityToken();
    return !!token;
  } catch(e) {
    console.error("checkiCloudStatus error", e);
    return false;
  }
  // #endif
  return false;
}

export function getUbiquityContainerPath() {
  // #ifdef APP-PLUS
  if (plus.os.name !== 'iOS') return null;
  try {
    var NSFileManager = plus.ios.importClass("NSFileManager");
    var defaultManager = NSFileManager.defaultManager();
    // null gets the first container defined in entitlements
    var url = defaultManager.URLForUbiquityContainerIdentifier_(null);
    if (url) {
      // Convert NSString to JS string if needed
      return String(url.path()); 
    }
  } catch(e) {
    console.error("getUbiquityContainerPath error", e);
  }
  // #endif
  return null;
}

/**
 * Sync local data object to iCloud Drive
 * @param {Object} dataObj - The full state object to sync
 */
export function syncToiCloud(dataObj) {
  // #ifdef APP-PLUS
  if (plus.os.name !== 'iOS') return;
  const path = getUbiquityContainerPath();
  if (!path) return; // iCloud not enabled or container not accessible

  const fullPath = path + "/Documents";
  
  try {
    var NSFileManager = plus.ios.importClass("NSFileManager");
    var defaultManager = NSFileManager.defaultManager();
    
    // Ensure Documents directory exists
    if (!defaultManager.fileExistsAtPath_(fullPath)) {
      defaultManager.createDirectoryAtPath_withIntermediateDirectories_attributes_error_(fullPath, true, null, null);
    }
    
    var filePath = fullPath + "/data.json";
    
    // Add a timestamp to know which data is newer
    const payload = {
      timestamp: Date.now(),
      data: dataObj
    };
    
    var content = JSON.stringify(payload);
    var NSString = plus.ios.importClass("NSString");
    var str = NSString.stringWithString_(content);
    // NSUTF8StringEncoding = 4
    str.writeToFile_atomically_encoding_error_(filePath, true, 4, null);
  } catch(e) {
    console.error("syncToiCloud write error", e);
  }
  // #endif
}

/**
 * Read data from iCloud Drive
 * @returns {Object|null} The parsed JSON object with {timestamp, data}
 */
export function readFromiCloud() {
  // #ifdef APP-PLUS
  if (plus.os.name !== 'iOS') return null;
  const path = getUbiquityContainerPath();
  if (!path) return null;
  
  const filePath = path + "/Documents/data.json";
  try {
    var NSFileManager = plus.ios.importClass("NSFileManager");
    var defaultManager = NSFileManager.defaultManager();
    
    if (defaultManager.fileExistsAtPath_(filePath)) {
      var NSString = plus.ios.importClass("NSString");
      var str = NSString.stringWithContentsOfFile_encoding_error_(filePath, 4, null);
      if (str) {
        var jsStr = String(str);
        if(jsStr) {
            return JSON.parse(jsStr);
        }
      }
    }
  } catch(e) {
    console.error("readFromiCloud error", e);
  }
  // #endif
  return null;
}

/**
 * Copy a local image to iCloud Ubiquity Container
 * @param {String} localFilePath - Local temp or saved file path
 * @param {String} fileName - Desired file name (e.g. timestamp.jpg)
 * @returns {String} The iCloud path if successful, otherwise original path
 */
export function copyImageToiCloud(localFilePath, fileName) {
    // #ifdef APP-PLUS
    if (plus.os.name !== 'iOS') return localFilePath;
    const path = getUbiquityContainerPath();
    if (!path) return localFilePath;
    
    const imagesDir = path + "/Documents/images";
    try {
        var NSFileManager = plus.ios.importClass("NSFileManager");
        var defaultManager = NSFileManager.defaultManager();
        
        if (!defaultManager.fileExistsAtPath_(imagesDir)) {
            defaultManager.createDirectoryAtPath_withIntermediateDirectories_attributes_error_(imagesDir, true, null, null);
        }
        
        var targetPath = imagesDir + "/" + fileName;
        var sourcePath = localFilePath.replace('file://', ''); // remove protocol if present
        
        // Overwrite if exists
        if (defaultManager.fileExistsAtPath_(targetPath)) {
            defaultManager.removeItemAtPath_error_(targetPath, null);
        }
        
        var success = defaultManager.copyItemAtPath_toPath_error_(sourcePath, targetPath, null);
        if (success) {
            return 'file://' + targetPath; // Return standard uni-app file URL
        }
    } catch(e) {
        console.error("iCloud image copy error", e);
    }
    // #endif
    return localFilePath;
}
