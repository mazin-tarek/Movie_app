# 🎬 خطة مشروع Movies App - Flutter (15 يوم)

**الأدوات:** Flutter | BLoC (flutter_bloc) | Firebase Auth | Clean Architecture + SOLID | YTS API | Dark/Light Theme | Responsive Design

> ملاحظة: العدد اليومي مرن حسب وقتك، بس الترتيب واللوجيك مهم يتحفظ. لو يوم مقدرتش تخلص، إحنا هننقل الباقي لليوم اللي بعده من غير ما نغير ترتيب المراحل.

---

## المرحلة 1: الأساس (Day 1-2) — Architecture + Theme

### Day 1 — إعداد المشروع + Clean Architecture
- [ ] إنشاء مشروع Flutter جديد + تنظيف الـ boilerplate
- [ ] بناء هيكل المجلدات (Clean Architecture 3 طبقات):
  ```
  lib/
    core/            (constants, theme, utils, errors, network)
    features/
      auth/
        data/        (models, datasources, repository_impl)
        domain/      (entities, repository (abstract), usecases)
        presentation/ (bloc, screens, widgets)
      movies/
        data/
        domain/
        presentation/
  ```
- [ ] شرح مبسط لكل مبدأ SOLID وإزاي هنطبقه فعليًا:
  - **S**RP → كل كلاس مسؤول عن حاجة واحدة (BLoC لا يعمل API calls مباشرة، الـ Repository هو المسؤول)
  - **O**CP → استخدام Abstract Repository عشان نقدر نغير المصدر (YTS → TMDB) من غير ما نلمس الكود اللي فوق
  - **L**SP → أي Implementation لل Repository لازم يشتغل مكان الـ Abstract بدون مشاكل
  - **I**SP → Interfaces صغيرة ومحددة (مش Repository واحد ضخم فيه كل حاجة)
  - **D**IP → الـ BLoC يعتمد على Abstract Repository مش على الـ Implementation (نستخدم `get_it` للـ Dependency Injection)
- [ ] تثبيت الباكدجات الأساسية: `flutter_bloc`, `equatable`, `get_it`, `dio`, `dartz` (أو `fpdart` للـ Either/Failure handling)
- [ ] عمل Firebase project + ربطه بالتطبيق (`flutterfire configure`)

### Day 2 — نظام الـ Theme (Dark/Light) + مقدمة BLoC
- [ ] بناء `AppTheme` (ThemeData لـ Light و Dark) بشكل منظم في `core/theme`
- [ ] عمل `ThemeCubit` بسيط (أول تجربة عملية لل BLoC) لحفظ اختيار المستخدم (Light/Dark/System) + حفظه محليًا (`shared_preferences`)
- [ ] **درس BLoC مصغر:** الفرق بين Cubit و Bloc، وEvents/States/Emit، ومتى تستخدم كل واحد
- [ ] بناء الـ Splash Screen بسيط بس Responsive من الأول (نستخدم `MediaQuery` / `LayoutBuilder`)

---

## المرحلة 2: Authentication (Day 3-4)

### Day 3 — Firebase Auth Logic
- [ ] إعداد `firebase_auth` + بناء `AuthRepository` (Abstract في domain + Implementation في data)
- [ ] بناء `AuthBloc` (Events: SignInRequested, SignUpRequested, SignOutRequested / States: Loading, Authenticated, Unauthenticated, Error)
- [ ] **درس:** إزاي تتعامل مع async errors جوه BLoC وتحولها لـ States واضحة بدل try/catch عشوائي

### Day 4 — Auth UI + Navigation
- [ ] بناء شاشات Login/Register (Responsive: تصميم يتمدد صح على أي مقاس)
- [ ] ربط الشاشات بـ `AuthBloc` باستخدام `BlocConsumer`/`BlocListener`
- [ ] إعداد Navigation (`go_router` مستحسن) + حماية المسارات (Auth Guard) بناءً على حالة الـ AuthBloc

---

## المرحلة 3: طبقة الـ API (Day 5-6) — هنا هنركز مع بعض أكتر لأنك ضعيف فيها

### Day 5 — Data Layer + الاتصال بـ YTS API
- [ ] **درس عملي كامل:** إزاي تتصل بـ API بـ Dio خطوة بخطوة (base_url, interceptors, error handling)
- [ ] بناء `MovieModel` (fromJson/toJson) + `MovieEntity` (الفرق بينهم وليه بنفصلهم)
- [ ] بناء `MovieRemoteDataSource` (بيكلم YTS API فعليًا: `list_movies.json`)
- [ ] بناء `MovieRepositoryImpl` (يحول Exceptions لـ Failures عن طريق `Either<Failure, List<Movie>>`)
- [ ] اختبار الاتصال بالـ API لوحده الأول (بدون UI) للتأكد إن البيانات بترجع صح

### Day 6 — MovieBloc + شاشة Home
- [ ] بناء `MovieBloc` (Events: FetchMovies, FetchNextPage / States: Loading, Loaded, Error, LoadingMore)
- [ ] **درس:** Pagination إزاي تشتغل مع BLoC (infinite scroll) بدون ما تعمل rebuild زيادة
- [ ] بناء UI شاشة Home بشكل أساسي (Grid/List) وربطها بالـ Bloc

---

## المرحلة 4: التصميم Responsive + التفاصيل (Day 7-8)

### Day 7 — Responsive Design الكامل
- [ ] **درس:** الفرق بين `MediaQuery`, `LayoutBuilder`, و`flutter_screenutil`
- [ ] تطبيق Grid ديناميكي (عدد الأعمدة يتغير حسب عرض الشاشة: موبايل صغير/كبير/تابلت)
- [ ] مراجعة كل الشاشات اللي عملناها لحد دلوقتي وتأكيد إنها Responsive فعلًا

### Day 8 — Movie Details Screen
- [ ] استدعاء `movie_details.json` من الـ API
- [ ] بناء `MovieDetailsBloc` مستقل (SRP: كل شاشة ليها Bloc خاص بيها)
- [ ] UI للتفاصيل (Poster, Rating, Genres, Summary, Trailer button) بشكل احترافي وResponsive

---

## المرحلة 5: الفيتشرز الأساسية (Day 9-11)

### Day 9 — Search
- [ ] بناء `SearchBloc` مع Debounce (عشان مايبعتش request مع كل حرف)
- [ ] **درس:** إزاي تعمل Debounce صح جوه BLoC (transformer / stream.debounceTime)
- [ ] UI للبحث + حالات (Loading, Empty Result, Error)

### Day 10 — Favorites (تخزين محلي)
- [ ] اختيار Local Storage: `Hive` (أسرع وأنضف من SharedPreferences للـ objects)
- [ ] بناء `FavoritesBloc` + Repository محلي منفصل عن API Repository (SRP)
- [ ] ربط زرار الـ Favorite في كل مكان (Home, Details) بنفس الـ Bloc

### Day 11 — فلترة حسب النوع (Genres) + اقتراحات مشابهة
- [ ] استخدام `movie_suggestions.json` في شاشة التفاصيل ("أفلام مشابهة")
- [ ] فلترة الـ Home حسب genre (نستخدم نفس الـ MovieBloc بحدث جديد FilterByGenre)

---

## المرحلة 6: الأداء والصقل (Day 12-13)

### Day 12 — Performance
- [ ] `cached_network_image` لكل الصور (تخزين مؤقت + placeholder + error widget)
- [ ] مراجعة `const` constructors في كل مكان ممكن
- [ ] تقليل الـ rebuilds الزيادة (استخدام `BlocSelector` بدل `BlocBuilder` في الأماكن المناسبة)
- [ ] فحص الأداء بـ Flutter DevTools (Widget rebuild count, frame rendering time)

### Day 13 — Testing
- [ ] Unit Tests لل BLoCs الأساسية (Auth, Movie, Favorites) باستخدام `bloc_test` + `mocktail`
- [ ] Unit Test لل Repository (mock الـ DataSource)
- [ ] **درس:** ليه الـ Clean Architecture بتخلي الاختبار أسهل بكتير (mock الطبقة اللي تحت بسهولة)

---

## المرحلة 7: التشطيب النهائي (Day 14-15)

### Day 14 — UX Polish
- [ ] Empty states, Error states, Shimmer loading effect بدل الـ CircularProgressIndicator العادي
- [ ] Animations بسيطة (Hero animation للانتقال من الـ Poster للـ Details)
- [ ] مراجعة الـ Dark/Light theme على كل الشاشات

### Day 15 — Final Review + Release
- [ ] مراجعة شاملة لتطبيق مبادئ SOLID على كل الملفات
- [ ] تنظيف الكود (remove unused imports, consistent naming)
- [ ] بناء Release APK (`flutter build apk --release`) واختباره على جهاز حقيقي
- [ ] كتابة README بسيط للمشروع (لو محتاجه لبورتفوليو)

---

## 📍 تتبع التقدم (حدّث السطر ده كل مرة)

**آخر تحديث:** لسه ما بدأناش
**آخر يوم خلصناه:** —
**واقفين عند:** —
**ملاحظات/تغييرات على الخطة:** —
