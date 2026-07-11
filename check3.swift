     1	import SwiftUI
     2	import WidgetKit
     3	import UniformTypeIdentifiers
     4	
     5	struct SettingsView: View {
     6	    @EnvironmentObject private var appSettings: AppSettings
     7	    @Environment(\.dismiss) private var dismiss
     8	    @Environment(\.modelContext) private var modelContext
     9	    
    10	    @State private var showingExport = false
    11	    @State private var showingImport = false
    12	    @State private var exportURL: URL?
    13	    
    14	    var body: some View {
    15	        NavigationView {
    16	            ScrollView(showsIndicators: false) {
    17	                VStack(spacing: DS.spacingL) {
    18	                    
    19	                    // Premium Banner
    20	                    if !appSettings.isPremium {
    21	                        Button(action: {
    22	                            appSettings.showPaywallFromSettings = true
    23	                        }) {
    24	                            HStack {
    25	                                VStack(alignment: .leading, spacing: 4) {
    26	                                    Text("Upgrade to Premium".tr(appSettings.resolvedLanguage))
    27	                                        .font(.system(size: 18, weight: .bold))
    28	                                        .foregroundColor(DS.onSurface)
    29	                                    Text("Unlock all features".tr(appSettings.resolvedLanguage))
    30	                                        .font(.system(size: 13, weight: .medium))
    31	                                        .foregroundColor(DS.onSurfaceVariant)
    32	                                }
    33	                                Spacer()
    34	                                Image(systemName: "crown.fill")
    35	                                    .font(.system(size: 24))
    36	                                    .foregroundColor(.yellow)
    37	                            }
    38	                            .padding(DS.spacingL)
    39	                            .background(
    40	                                RoundedRectangle(cornerRadius: 24, style: .continuous)
    41	                                    .fill(DS.surface)
    42	                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    43	                            )
    44	                        }
    45	                        .buttonStyle(.plain)
    46	                        .padding(.horizontal, DS.spacingL)
    47	                        .padding(.top, DS.spacingS)
    48	                    } else {
    49	                        HStack {
    50	                            VStack(alignment: .leading, spacing: 4) {
    51	                                Text("Premium Member".tr(appSettings.resolvedLanguage))
    52	                                    .font(.system(size: 18, weight: .bold))
    53	                                    .foregroundColor(DS.onSurface)
    54	                                Text("All features unlocked".tr(appSettings.resolvedLanguage))
    55	                                    .font(.system(size: 13, weight: .medium))
    56	                                    .foregroundColor(DS.onSurfaceVariant)
    57	                            }
    58	                            Spacer()
    59	                            Image(systemName: "crown.fill")
    60	                                .font(.system(size: 24))
    61	                                .foregroundColor(.yellow)
    62	                        }
    63	                        .padding(DS.spacingL)
    64	                        .background(
    65	                            RoundedRectangle(cornerRadius: 24, style: .continuous)
    66	                                .fill(DS.surface)
    67	                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    68	                        )
    69	                        .padding(.horizontal, DS.spacingL)
    70	                        .padding(.top, DS.spacingS)
    71	                    }
    72	
    73	                    // Appearance & General
    74	                    SettingsSection(title: "Appearance".tr(appSettings.resolvedLanguage)) {
    75	                        
    76	                        // Dark Mode
    77	                        if appSettings.isPremium {
    78	                            Menu {
    79	                                Picker("", selection: $appSettings.themeMode) {
    80	                                    ForEach(AppTheme.allCases) { theme in
    81	                                        Text(theme.displayName(in: appSettings.resolvedLanguage)).tag(theme)
    82	                                    }
    83	                                }
    84	                                .onChange(of: appSettings.themeMode) { _ in
    85	                                    appSettings.objectWillChange.send()
    86	                                    WidgetCenter.shared.reloadAllTimelines()
    87	                                }
    88	                            } label: {
    89	                                SettingsRowLabel(icon: "moon.stars", color: DS.primary, title: "Dark Mode".tr(appSettings.resolvedLanguage), value: appSettings.themeMode.displayName(in: appSettings.resolvedLanguage), isPremiumFeature: false, isPremiumUser: true)
    90	                            }
    91	                        } else {
    92	                            Button { appSettings.showPaywallFromSettings = true } label: {
    93	                                SettingsRowLabel(icon: "moon.stars", color: DS.primary, title: "Dark Mode".tr(appSettings.resolvedLanguage), value: appSettings.themeMode.displayName(in: appSettings.resolvedLanguage), isPremiumFeature: true, isPremiumUser: false)
    94	                            }
    95	                        }
    96	                        
    97	                        Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, DS.spacingL)
    98	                        
    99	                        // Theme Color Picker
   100	                        VStack(alignment: .leading, spacing: DS.spacingM) {
   101	                            HStack {
   102	                                ZStack {
   103	                                    Circle().fill(DS.accent.opacity(0.15)).frame(width: 40, height: 40)
   104	                                    Image(systemName: "paintpalette").font(.system(size: 18, weight: .medium)).foregroundColor(DS.accent)
   105	                                }
   106	                                Text("Theme Color".tr(appSettings.resolvedLanguage))
   107	                                    .labelMd()
   108	                                    .foregroundColor(DS.onSurface)
   109	                                Spacer()
   110	                                if !appSettings.isPremium {
   111	                                    Image(systemName: "lock.fill").foregroundColor(.orange).font(.system(size: 14))
   112	                                }
   113	                            }
   114	                            .contentShape(Rectangle())
   115	                            .onTapGesture {
   116	                                if !appSettings.isPremium {
   117	                                    appSettings.showPaywallFromSettings = true
   118	                                }
   119	                            }
   120	                            
   121	                            ScrollView(.horizontal, showsIndicators: false) {
   122	                                HStack(spacing: 12) {
   123	                                    let colors = ["#5e4dbb", "#2E8B57", "#4169E1", "#E07A5F", "#D72638", "#8D6E63", "#F4A261", "#607D8B", "#2A9D8F", "#F28482"]
   124	                                    ForEach(colors, id: \.self) { hex in
   125	                                        Circle()
   126	                                            .fill(Color(hex: hex))
   127	                                            .frame(width: 36, height: 36)
   128	                                            .overlay(Circle().stroke(Color.white, lineWidth: appSettings.themeColorHex == hex ? 3 : 0))
   129	                                            .shadow(color: Color(hex: hex).opacity(0.4), radius: appSettings.themeColorHex == hex ? 6 : 0)
   130	                                            .scaleEffect(appSettings.themeColorHex == hex ? 1.1 : 1.0)
   131	                                            .onTapGesture {
   132	                                                if !appSettings.isPremium {
   133	                                                    appSettings.showPaywallFromSettings = true
   134	                                                } else {
   135	                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
   136	                                                        appSettings.themeColorHex = hex
   137	                                                        appSettings.objectWillChange.send()
   138	                                                    }
   139	                                                }
   140	                                            }
   141	                                    }
   142	                                }
   143	                                .padding(.vertical, 8)
   144	                                .padding(.horizontal, 4)
   145	                            }
   146	                        }
   147	                        .padding(.horizontal, DS.spacingL)
   148	                        .padding(.vertical, 12)
   149	                        
   150	                        Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, DS.spacingL)
   151	                        
   152	                        // Start of Week
   153	                        Menu {
   154	                            Picker("", selection: $appSettings.firstWeekday) {
   155	                                Text("Monday".tr(appSettings.resolvedLanguage)).tag(2)
   156	                                Text("Sunday".tr(appSettings.resolvedLanguage)).tag(1)
   157	                            }
   158	                            .onChange(of: appSettings.firstWeekday) { _ in appSettings.objectWillChange.send() }
   159	                        } label: {
   160	                            SettingsRowLabel(icon: "calendar", color: DS.secondary, title: "Start of Week".tr(appSettings.resolvedLanguage), value: appSettings.firstWeekday == 2 ? "Monday".tr(appSettings.resolvedLanguage) : "Sunday".tr(appSettings.resolvedLanguage), isPremiumFeature: false, isPremiumUser: true)
   161	                        }
   162	                    }
   163	                    
   164	                    // Language
   165	                    SettingsSection(title: "Language".tr(appSettings.resolvedLanguage)) {
   166	                        Menu {
   167	                            Picker("", selection: $appSettings.language) {
   168	                                ForEach(AppLanguage.allCases) { lang in
   169	                                    Text(lang.displayName).tag(lang)
   170	                                }
   171	                            }
   172	                            .onChange(of: appSettings.language) { _ in appSettings.objectWillChange.send() }
   173	                        } label: {
   174	                            SettingsRowLabel(icon: "globe", color: DS.tertiary, title: "Language".tr(appSettings.resolvedLanguage), value: appSettings.language.displayName, isPremiumFeature: false, isPremiumUser: true)
   175	                        }
   176	                    }
   177	                    
   178	                    // App Lock
   179	                    SettingsSection(title: "App Lock".tr(appSettings.resolvedLanguage)) {
   180	                        Button {
   181	                            if !appSettings.isPremium {
   182	                                appSettings.showPaywallFromSettings = true
   183	                            } else {
   184	                                appSettings.appLockEnabled.toggle()
   185	                            }
   186	                        } label: {
   187	                            SettingsRowLabel(icon: "lock.shield", color: .green, title: "App Lock".tr(appSettings.resolvedLanguage), value: appSettings.appLockEnabled ? "On".tr(appSettings.resolvedLanguage) : "Off".tr(appSettings.resolvedLanguage), isPremiumFeature: true, isPremiumUser: appSettings.isPremium)
   188	                        }
   189	                    }
   190	                    
   191	                    // Data
   192	                    SettingsSection(title: "Data".tr(appSettings.resolvedLanguage)) {
   193	                        
   194	                        // iCloud Sync
   195	                        Button {
   196	                            if !appSettings.isPremium {
   197	                                appSettings.showPaywallFromSettings = true
   198	                            } else {
   199	                                appSettings.iCloudSyncEnabled.toggle()
   200	                            }
   201	                        } label: {
   202	                            SettingsRowLabel(icon: "icloud", color: .cyan, title: "iCloud Sync".tr(appSettings.resolvedLanguage), value: appSettings.iCloudSyncEnabled ? "On".tr(appSettings.resolvedLanguage) : "Off".tr(appSettings.resolvedLanguage), isPremiumFeature: true, isPremiumUser: appSettings.isPremium)
   203	                        }
   204	                        
   205	                        Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, DS.spacingL)
   206	                        
   207	                        // Import
   208	                        Button {
   209	                            if !appSettings.isPremium {
   210	                                appSettings.showPaywallFromSettings = true
   211	                            } else {
   212	                                showingImport = true
   213	                            }
   214	                        } label: {
   215	                            SettingsRowLabel(icon: "arrow.down.doc", color: .blue, title: "Import Data".tr(appSettings.resolvedLanguage), value: "", isPremiumFeature: true, isPremiumUser: appSettings.isPremium)
   216	                        }
   217	                        
   218	                        Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, DS.spacingL)
   219	                        
   220	                        // Export
   221	                        Button {
   222	                            if !appSettings.isPremium {
   223	                                appSettings.showPaywallFromSettings = true
   224	                            } else {
   225	                                if let url = DataBackupManager.shared.exportData(modelContext: modelContext) {
   226	                                    exportURL = url
   227	                                    showingExport = true
   228	                                }
   229	                            }
   230	                        } label: {
   231	                            SettingsRowLabel(icon: "arrow.up.doc", color: .pink, title: "Export Data".tr(appSettings.resolvedLanguage), value: "", isPremiumFeature: true, isPremiumUser: appSettings.isPremium)
   232	                        }
   233	                    }
   234	                    
   235	                    // About
   236	                    SettingsSection(title: "About".tr(appSettings.resolvedLanguage)) {
   237	                        Button {
   238	                            // Dummy Action
   239	                        } label: {
   240	                            SettingsRowLabel(icon: "doc.text", color: .gray, title: "Terms of Service".tr(appSettings.resolvedLanguage), value: "", isPremiumFeature: false, isPremiumUser: true)
   241	                        }
   242	                        
   243	                        Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, DS.spacingL)
   244	                        
   245	                        Button {
   246	                            // Dummy Action
   247	                        } label: {
   248	                            SettingsRowLabel(icon: "hand.raised", color: .gray, title: "Privacy Policy".tr(appSettings.resolvedLanguage), value: "", isPremiumFeature: false, isPremiumUser: true)
   249	                        }
   250	                    }
   251	                    
   252	                }
   253	                    // Developer Testing
   254	                    SettingsSection(title: "Developer (Test Only)".tr(appSettings.resolvedLanguage)) {
   255	                        Toggle(isOn: $appSettings.isPremium) {
   256	                            Text("Mock Premium Status".tr(appSettings.resolvedLanguage))
   257	                                .labelMd()
   258	                                .foregroundColor(DS.onSurface)
   259	                        }
   260	                        .padding(.horizontal, DS.spacingL)
   261	                        .padding(.vertical, 12)
   262	                        .tint(DS.primary)
   263	                    }
   264	
   265	                }
   266	                .padding(.bottom, 40)
   267	            }
   268	            .background(DS.bgPrimary)
   269	            .navigationTitle("Settings".tr(appSettings.resolvedLanguage))
   270	            .navigationBarTitleDisplayMode(.inline)
   271	            .toolbar {
   272	                ToolbarItem(placement: .navigationBarTrailing) {
   273	                    Button(action: { dismiss() }) {
   274	                        Text("关闭")
   275	                            .foregroundColor(DS.primary)
   276	                            .font(.system(size: 16, weight: .medium))
   277	                    }
   278	                }
   279	            }
   280	            .fileExporter(isPresented: $showingExport, document: JSONDocument(url: exportURL), contentType: .json, defaultFilename: "LittleHabitBackup") { result in
   281	                // Handle result
   282	            }
   283	            .fileImporter(isPresented: $showingImport, allowedContentTypes: [.json]) { result in
   284	                switch result {
   285	                case .success(let url):
   286	                    DataBackupManager.shared.importData(from: url, modelContext: modelContext)
   287	                case .failure(let err):
   288	                    print("Import failed: \(err)")
   289	                }
   290	            }
   291	        }
   292	        .sheet(isPresented: $appSettings.showPaywallFromSettings) {
   293	            PaywallView()
   294	                .presentationDragIndicator(.visible)
   295	        }
   296	    }
   297	}
   298	
   299	struct JSONDocument: FileDocument {
   300	    static var readableContentTypes: [UTType] { [.json] }
   301	    var url: URL?
   302	    init(url: URL?) { self.url = url }
   303	    init(configuration: ReadConfiguration) throws { }
   304	    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
   305	        if let url = url { return try FileWrapper(url: url, options: .immediate) }
   306	        return FileWrapper(regularFileWithContents: Data())
   307	    }
   308	}
   309	
   310	struct SettingsSection<Content: View>: View {
   311	    let title: String
   312	    let content: Content
   313	    
   314	    init(title: String, @ViewBuilder content: () -> Content) {
   315	        self.title = title
   316	        self.content = content()
   317	    }
   318	    
   319	    var body: some View {
   320	        VStack(alignment: .leading, spacing: DS.spacingS) {
   321	            Text(title)
   322	                .font(.system(size: 14, weight: .bold))
   323	                .foregroundColor(DS.onSurfaceVariant)
   324	                .padding(.horizontal, DS.spacingL)
   325	                .padding(.leading, 8)
   326	            
   327	            VStack(spacing: 0) {
   328	                content
   329	            }
   330	            .buttonStyle(.plain) // This makes any buttons inside this stack render normally without default button styling, but their touch area is active.
   331	            .background(
   332	                DS.surface.opacity(0.7)
   333	            )
   334	            .background(.ultraThinMaterial)
   335	            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
   336	            .overlay(
   337	                RoundedRectangle(cornerRadius: 24, style: .continuous)
   338	                    .stroke(DS.outlineVariant, lineWidth: 1)
   339	            )
   340	            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
   341	            .padding(.horizontal, DS.spacingL)
   342	        }
   343	    }
   344	}
   345	
   346	struct SettingsRowLabel: View {
   347	    let icon: String
   348	    let color: Color
   349	    let title: String
   350	    let value: String
   351	    let isPremiumFeature: Bool
   352	    let isPremiumUser: Bool
   353	    
   354	    var body: some View {
   355	        HStack(spacing: DS.spacingM) {
   356	            ZStack {
   357	                Circle().fill(color.opacity(0.15)).frame(width: 40, height: 40)
   358	                Image(systemName: icon).font(.system(size: 18, weight: .medium)).foregroundColor(color)
   359	            }
   360	            
   361	            Text(title).labelMd().foregroundColor(DS.onSurface)
   362	            
   363	            Spacer()
   364	            
   365	            if !value.isEmpty {
   366	                Text(value).labelMd().foregroundColor(DS.onSurfaceVariant)
   367	            }
   368	            
   369	            if isPremiumFeature && !isPremiumUser {
   370	                Image(systemName: "lock.fill").font(.system(size: 14)).foregroundColor(.orange)
   371	            } else {
   372	                Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(DS.onSurfaceVariant.opacity(0.5))
   373	            }
   374	        }
   375	        .padding(.horizontal, DS.spacingL)
   376	        .padding(.vertical, 12)
   377	        .contentShape(Rectangle()) // Makes the whole row touchable
   378	    }
   379	}
