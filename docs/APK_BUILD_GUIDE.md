# دليل بناء حزم أندرويد (Android APK & App Bundle Build Guide)
## Pizza Awlad Alsheikh – بيتزا أولاد الشيخ

يوضح هذا الدليل خطوات استخراج ملف الـ APK أو Google Play App Bundle (AAB) لتطبيق بيتزا أولاد الشيخ.

---

### أولاً: بناء نسخة تجريبية سريعة (Debug APK)
إذا أردت تثبيت التطبيق فوراً على هاتفك المحمول أو إرساله عبر واتساب لأصحاب المطعم لتجربته:

1. افتح الطرفية وانتقل لمجلد تطبيق الموبايل:
```powershell
cd d:\بيتزا\mobile_app
```

2. نفذ أمر بناء الـ Debug APK:
```powershell
flutter build apk --debug
```

3. ستجد ملف الـ APK جاهزاً في المسار:
```text
mobile_app/build/app/outputs/flutter-apk/app-debug.apk
```
يمكنك نقله مباشرة إلى أي هاتف أندرويد وتثبيته.

---

### ثانياً: بناء النسخة الإنتاجية (Release APK)

1. نفذ الأمر:
```powershell
cd d:\بيتزا\mobile_app
flutter build apk --release
```

2. أو لبناء APK مقسم حسب المعالجات لتقليل حجم التطبيق (Split per ABI):
```powershell
flutter build apk --split-per-abi
```
سينتج ثلاثة ملفات خفيفة الحجم:
- `app-armeabi-v7a-release.apk` (للهواتف الأقدم)
- `app-arm64-v8a-release.apk` (لمعظم الهواتف الحديثة - يوصى به)
- `app-x86_64-release.apk` (للمحاكيات)

---

### ثالثاً: توقيع التطبيق لمتجر Google Play (Keystore Signing)

1. **إنشاء مفتاح التوقيع الرقمي (Keystore):**
```powershell
keytool -genkey -v -keystore pizza_release_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pizza_key
```

2. **إنشاء ملف `android/key.properties`:**
```properties
storePassword=كلمة_المرور_المختارة
keyPassword=كلمة_المرور_المختارة
keyAlias=pizza_key
storeFile=../pizza_release_key.jks
```

3. **بناء حزمة متجر جوجل الرسمية (App Bundle):**
```powershell
flutter build appbundle --release
```
ستجد الملف الناتج في المسار:
```text
mobile_app/build/app/outputs/bundle/release/app-release.aab
```
وهذا هو الملف المعتمد لرفعه إلى Google Play Console.
