When the user says '提交 git' (submit git), ALWAYS run 'git push' to push the commits to the remote repository after committing.

<RULE>
多语言规范约束：
后续所有涉及显示文案的修改、新增，都必须遵循多语言配置的原则：
1. 所有的多语言 Key 必须定义为 `L10n`（在 `Constants.swift` 中）的 `static let` 常量（英文驼峰命名，如 `static let recordMood = "Record Mood"`）。
2. 需要在 `String.translations` 字典中添加对应的中英文翻译映射。
3. 在代码中调用时，统一使用 `L10n.常量名.tr(语言)` 或 `L10n.常量名.wTr()`（仅限小组件）来进行多语言解析，严禁在代码中写死中文原生字符串调用翻译方法。
</RULE>
