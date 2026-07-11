import os

model_dir = "/Users/xiaodao/Desktop/scratch/little-habit-tracker_ios/LittleHabitTracker.xcdatamodeld/LittleHabitTracker.xcdatamodel"
os.makedirs(model_dir, exist_ok=True)

xml_content = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<model type="com.apple.IDECoreDataModeler.DataModel" documentVersion="1.0" lastSavedToolsVersion="1" systemVersion="11A511" minimumToolsVersion="Xcode 4.3" sourceLanguage="Swift" userDefinedModelVersionIdentifier="">
    <entity name="Checkin" representedClassName="Checkin" syncable="YES" codeGenerationType="class">
        <attribute name="amount" optional="YES" attributeType="Double" defaultValueString="0.0"/>
        <attribute name="dateString" optional="YES" attributeType="String" defaultValueString=""/>
        <attribute name="id" optional="YES" attributeType="String"/>
        <attribute name="timestamp" optional="YES" attributeType="Date"/>
        <relationship name="habit" optional="YES" maxCount="1" deletionRule="Nullify" destinationEntity="Habit" inverseName="checkins" inverseEntity="Habit"/>
    </entity>
    <entity name="Habit" representedClassName="Habit" syncable="YES" codeGenerationType="class">
        <attribute name="amountUnit" optional="YES" attributeType="String" defaultValueString=""/>
        <attribute name="amountValue" optional="YES" attributeType="Double" defaultValueString="0.0"/>
        <attribute name="color" optional="YES" attributeType="String" defaultValueString="#8B5CF6"/>
        <attribute name="createdAt" optional="YES" attributeType="Date"/>
        <attribute name="frequencyType" optional="YES" attributeType="String" defaultValueString="weekly"/>
        <attribute name="goalType" optional="YES" attributeType="String" defaultValueString="frequency"/>
        <attribute name="icon" optional="YES" attributeType="String" defaultValueString="star.fill"/>
        <attribute name="id" optional="YES" attributeType="String"/>
        <attribute name="isArchived" optional="YES" attributeType="Boolean" defaultValueString="NO"/>
        <attribute name="isReminderEnabled" optional="YES" attributeType="Boolean" defaultValueString="NO"/>
        <attribute name="monthlyTarget" optional="YES" attributeType="Integer 64" defaultValueString="10"/>
        <attribute name="name" optional="YES" attributeType="String" defaultValueString=""/>
        <attribute name="order" optional="YES" attributeType="Integer 64" defaultValueString="0"/>
        <attribute name="reminderText" optional="YES" attributeType="String" defaultValueString=""/>
        <attribute name="reminderTime" optional="YES" attributeType="Date"/>
        <attribute name="weeklyTarget" optional="YES" attributeType="Integer 64" defaultValueString="3"/>
        <relationship name="checkins" optional="YES" toMany="YES" deletionRule="Cascade" destinationEntity="Checkin" inverseName="habit" inverseEntity="Checkin"/>
        <relationship name="moodRecords" optional="YES" toMany="YES" deletionRule="Cascade" destinationEntity="MoodRecord" inverseName="habit" inverseEntity="MoodRecord"/>
    </entity>
    <entity name="MoodRecord" representedClassName="MoodRecord" syncable="YES" codeGenerationType="class">
        <attribute name="id" optional="YES" attributeType="String"/>
        <attribute name="imageData" optional="YES" attributeType="Binary" allowsExternalBinaryDataStorage="YES"/>
        <attribute name="text" optional="YES" attributeType="String" defaultValueString=""/>
        <attribute name="timestamp" optional="YES" attributeType="Date"/>
        <attribute name="type" optional="YES" attributeType="String" defaultValueString="normal"/>
        <relationship name="habit" optional="YES" maxCount="1" deletionRule="Nullify" destinationEntity="Habit" inverseName="moodRecords" inverseEntity="Habit"/>
    </entity>
</model>
"""

with open(os.path.join(model_dir, "contents"), "w") as f:
    f.write(xml_content)

print("Generated xcdatamodeld successfully.")
