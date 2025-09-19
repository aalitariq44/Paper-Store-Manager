# إعداد Firebase للتطبيق

## الخطوات المطلوبة لإعداد Firebase

### 1. إنشاء مشروع Firebase جديد
1. اذهب إلى [Firebase Console](https://console.firebase.google.com/)
2. اضغط على "إضافة مشروع" أو "Add project"
3. اختر اسم المشروع (مثل: paper-store-manager)
4. اتبع خطوات الإعداد

### 2. إعداد Firestore Database
1. من لوحة تحكم Firebase، اذهب إلى "Firestore Database"
2. اضغط على "إنشاء قاعدة بيانات" أو "Create database"
3. اختر "Start in test mode" (للتطوير) أو اضبط القوانين حسب حاجتك
4. اختر الموقع الجغرافي الأقرب لك

### 3. إعداد Firebase Storage
1. من لوحة تحكم Firebase، اذهب إلى "Storage"
2. اضغط على "البدء" أو "Get started"
3. اقبل القواعد الافتراضية أو اضبطها حسب حاجتك

### 4. إضافة التطبيق للمشروع

#### لنظام Android:
1. في لوحة تحكم Firebase، اضغط على "إضافة تطبيق" واختر Android
2. أدخل package name: `com.example.paperStoreManager`
3. حمّل ملف `google-services.json`
4. ضع الملف في: `android/app/`

#### لنظام iOS:
1. في لوحة تحكم Firebase، اضغط على "إضافة تطبيق" واختر iOS
2. أدخل bundle ID: `com.example.paperStoreManager`
3. حمّل ملف `GoogleService-Info.plist`
4. ضع الملف في: `ios/Runner/`

### 5. قواعد Firestore (Firestore Rules)

يمكنك استخدام هذه القوانين البسيطة للتطوير:

```javascript
// قوانين بسيطة للتطوير - تسمح بالقراءة والكتابة للجميع
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**للإنتاج، استخدم قوانين أكثر أماناً:**

```javascript
// قوانين آمنة للإنتاج
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // قوانين مجموعة الإدارة
    match /admin/{document} {
      allow read, write: if true; // يمكن تخصيصها أكثر
    }
    
    // قوانين مجموعة التصنيفات
    match /categories/{document} {
      allow read, write: if true;
    }
    
    // قوانين مجموعة المنتجات
    match /products/{document} {
      allow read, write: if true;
    }
  }
}
```

### 6. قوانين Firebase Storage

```javascript
// قوانين Storage
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /product_images/{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

## إعداد كلمة المرور لأول مرة

### الطريقة الأولى: باستخدام شاشة الإعداد المخفية
1. في شاشة تسجيل الدخول، اضغط لفترة طويلة على المنطقة السفلية (النقطة الصغيرة)
2. ستظهر شاشة "إعداد كلمة المرور"
3. أدخل كلمة المرور المطلوبة (أكثر من 6 أحرف)
4. اضغط "حفظ كلمة المرور"

### الطريقة الثانية: يدوياً عبر Firestore Console
1. اذهب إلى Firestore في لوحة تحكم Firebase
2. أنشئ مجموعة جديدة باسم `admin`
3. أنشئ مستند بـ ID: `credentials`
4. أضف حقل:
   - Key: `password`
   - Type: `string`
   - Value: `كلمة_المرور_المطلوبة`

## اختبار التطبيق

1. تأكد من اتصال الجهاز بالإنترنت
2. شغّل التطبيق: `flutter run`
3. أدخل كلمة المرور التي تم إعدادها
4. اختبر إضافة تصنيف جديد
5. اختبر إضافة منتج جديد مع صورة

## استكشاف الأخطاء

### مشاكل شائعة وحلولها:

1. **خطأ في الاتصال بـ Firebase:**
   - تأكد من إعداد `google-services.json` و `GoogleService-Info.plist` بشكل صحيح
   - تأكد من تفعيل Firestore و Storage

2. **خطأ في رفع الصور:**
   - تأكد من تفعيل Firebase Storage
   - تحقق من قوانين Storage

3. **لا يمكن تسجيل الدخول:**
   - تأكد من إعداد كلمة المرور في Firestore
   - تحقق من قوانين Firestore للمجموعة `admin`

4. **مشاكل الصلاحيات:**
   - للأندرويد: أضف صلاحيات الكاميرا والمعرض في `android/app/src/main/AndroidManifest.xml`
   - للـ iOS: أضف صلاحيات الكاميرا والمعرض في `ios/Runner/Info.plist`

### صلاحيات Android (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### صلاحيات iOS (Info.plist):
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos of products</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select product images</string>
```