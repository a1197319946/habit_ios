import re

with open('Sources/Info.plist', 'r') as f:
    code = f.read()

new_keys = """	<key>UILaunchScreen</key>
	<dict/>
	<key>NSPhotoLibraryAddUsageDescription</key>
	<string>我们需要保存心情卡片图片到您的相册 (We need access to save mood images to your photo library)</string>"""

code = code.replace("	<key>UILaunchScreen</key>\n	<dict/>", new_keys)

with open('Sources/Info.plist', 'w') as f:
    f.write(code)

