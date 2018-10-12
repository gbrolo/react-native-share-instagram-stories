# react-native-share-instagram-stories

## Getting started

`$ npm install react-native-share-instagram-stories --save`

### Mostly automatic installation

`$ react-native link react-native-share-instagram-stories`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-share-instagram-stories` and add `RNShareInstagramStories.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNShareInstagramStories.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

You may also use CocoaPod spec: `ios/RNShareInstagramStories.podspec`:

```
pod "RNShareInstagramStories", :path => '../node_modules/react-native-share-instagram-stories/ios'
```

+ add `instagram-stories` to the `LSApplicationQueriesSchemes` key in your app's Info.plist.

```
...
<key>LSApplicationQueriesSchemes</key>
<array>
	...
	<string>instagram-stories</string>
</array>
...
```

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNShareInstagramStoriesPackage;` to the imports at the top of the file
  - Add `new RNShareInstagramStoriesPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-share-instagram-stories'
  	project(':react-native-share-instagram-stories').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-share-instagram-stories/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-share-instagram-stories')
  	```
