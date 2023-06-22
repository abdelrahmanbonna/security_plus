# security_plus

This is a Dart/Flutter plugin to know if the device security has been breached or not. For example it will let you know if the user rooted his device or not.

Please Note: [isRooted] and [isJailBroken] are both async functions which returns a boolean use them wisely.

## install:
```dart
dependencies:
   security_plus: ^1.0.0
```

## use:

```dart

// You could use [isRooted] to check if the android device is rooted or not 
  SecurityPlus.isRooted

// You could use [isJailBroken] to check if the IOS device is jail broken or not 
  SecurityPlus.isJailBroken

```


## Credits

Thanks to [abu](https://github.com/abu0306) for creating flutter_root_jailbreak which was the base for this plugin.