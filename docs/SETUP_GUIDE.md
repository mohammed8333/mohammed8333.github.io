# دليل التثبيت والتشغيل الشامل – مطعم بيتزا أولاد الشيخ
## Pizza Awlad Alsheikh - Setup & Execution Guide

يحتوي هذا الدليل على كافة التعليمات اللازمة لتشغيل الواجهة الخلفية (Backend API)، قاعدة البيانات (PostgreSQL / SQLite)، وتطبيق الهاتف المحمول (Flutter Mobile App).

---

### المتطلبات الأساسية (Prerequisites)
1. **.NET SDK** (الإصدار 8.0 أو 9.0 أو 10.0 مثبت).
2. **Flutter SDK** (الإصدار 3.20+ مع لغة Dart 3.4+).
3. **Android Studio أو Android SDK** (لبناء وتشغيل نسخة أندرويد).
4. متصفح **Google Chrome** أو **Edge** (لتشغيل نسخة الويب الفورية).
5. **PostgreSQL** (اختياري، مدمج مع دعم SQLite التلقائي للتشغيل الفوري).

---

### أولاً: تشغيل الواجهة الخلفية (ASP.NET Core Web API)

المشروع يقع في المسار:
```bash
d:\بيتزا\backend\PizzaAwladAlsheikh.API
```

#### 1. استعادة الحزم وبناء المشروع:
```powershell
cd d:\بيتزا\backend\PizzaAwladAlsheikh.API
dotnet restore
dotnet build
```

#### 2. ضبط قاعدة البيانات:
في ملف `appsettings.json`:
- الوضع الافتراضي مضبوط على `Sqlite` ليعمل مباشرة بدون الحاجة لتثبيت أي خادم خارجي:
```json
{
  "DatabaseProvider": "Sqlite",
  "ConnectionStrings": {
    "Sqlite": "Data Source=pizza_awlad_alsheikh.db",
    "PostgreSQL": "Host=localhost;Port=5432;Database=pizza_awlad_alsheikh;Username=postgres;Password=postgres"
  }
}
```
- إذا كنت ترغب في استخدام خادم **PostgreSQL** في الإنتاج:
غيّر قيمة `"DatabaseProvider"` إلى `"PostgreSQL"` وضع بيانات الاتصال الخاصة بك في `"ConnectionStrings:PostgreSQL"`.

#### 3. تشغيل الخادم:
```powershell
dotnet run
```
سيعمل الخادم تلقائياً ويقوم بإنشاء الجداول وحقن البيانات التجريبية (Seeding) تلقائياً، ويعمل على المنفذ:
`http://localhost:5000` أو `https://localhost:5001`.

رابط فحص صحة الخادم:
`http://localhost:5000/`

رابط توثيق الـ API (OpenAPI / Swagger):
`http://localhost:5000/openapi/v1.json`

بيانات دخول الإدارة الافتراضية:
- اسم المستخدم: `admin`
- كلمة المرور: `AdminPassword123!`

---

### ثانياً: تشغيل تطبيق الموبايل (Flutter Application)

المشروع يقع في المسار:
```bash
d:\بيتزا\mobile_app
```

#### 1. استعادة الحزم:
```powershell
cd d:\بيتزا\mobile_app
flutter pub get
```

#### 2. تشغيل الاختبارات للتأكد من سلامة النظام:
```powershell
flutter test
```

#### 3. تشغيل التطبيق على الويب (Google Chrome):
```powershell
flutter run -d chrome
```

#### 4. تشغيل التطبيق على محاكي أندرويد (Android Emulator) أو جهاز حقيقي:
- تأكد من تشغيل المحاكي أو توصيل الهاتف وتفعيل وضع تصحيح أخطاء USB (USB Debugging).
- نفذ الأمر:
```powershell
flutter run
```

---

### ثالثاً: ميزة العمل بدون إنترنت (Offline Mode)
تم تصميم التطبيق بذكاء بحيث:
- في حال كان خادم الـ API قيد التشغيل: يتصل مباشرة به ويزامن البيانات والطلبات.
- في حال كان الهاتف غير متصل بالخادم أو يعمل بنظام Standalone: يعتمد التطبيق تلقائياً على مخزن البيانات المحلي (Offline Data Provider) ويعمل التطبيق وسلة الطلبات وحساب الأسعار وتوليد رسائل واتساب بكفاءة 100%.
