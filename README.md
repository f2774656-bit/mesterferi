# پنل پروکسی مستر ایرانفا | MASTER IRANFA

**POWERED BY MASTER IRANFA**

پنل فارسی و RTL برای کنترل یک سرویس Telegram MTProto بر پایه موتور واقعی [mtg v2.3.0](https://github.com/9seconds/mtg). فرانت‌اند React + TypeScript و بک‌اند Node.js/Express است. اطلاعات پایدار در SQLite روی Volume ذخیره می‌شود.

## قابلیت‌های پیاده‌سازی‌شده

- ورود مدیر با هش bcrypt، کوکی HttpOnly/SameSite، نشست سمت سرور، CSRF token و محدودیت تلاش ورود.
- اجرای واقعی `mtg run CONFIG.toml`، توقف و راه‌اندازی مجدد پردازه.
- Secret تصادفی ۱۶ بایتی (hex)، چرخاندن Secret، لینک `https://t.me/proxy` و QR محلی.
- بررسی TCP داخلی با اتصال واقعی به `127.0.0.1:MTG_PORT`.
- وضعیت پردازه، RSS/Heap پنل، Load متوسط میزبان، زمان فعالیت پنل و رویدادهای ذخیره‌شده.
- پشتیبان‌گیری JSON از تنظیمات پروکسی، تغییر رمز مدیر، حذف رویدادها.
- رابط فارسی RTL واکنش‌گرا با استفاده از لوگوی ارائه‌شده.

## محدودیت‌های صریح موتور و Railway

- mtg یک Secret برای یک Listener/پروکسی در هر پردازه پیکربندی‌شده ارائه می‌کند؛ این محصول در این نسخه یک پروکسی اصلی را مدیریت می‌کند.
- mtg قابلیت مدیریت هویت کاربران نهایی، محدودیت مصرف/انقضا برای هر کاربر، شمارش کاربران تلگرام یا سهمیه‌بندی اختصاصی را ارائه نمی‌کند؛ به همین دلیل چنین امکاناتی به‌صورت ساختگی در UI وجود ندارند.
- Railway برای هر Service Instance فقط یک TCP Proxy عمومی می‌سازد. چندین endpoint مستقل برای چند پروکسی، مستلزم چند سرویس Railway/معماری جداگانه است.
- Railway دامنه و پورت TCP Proxy را در داشبورد نمایش می‌دهد. برنامه آن‌ها را از محیط به‌طور قابل اتکا کشف نمی‌کند؛ مقادیر `PUBLIC_TCP_HOST` و `PUBLIC_TCP_PORT` باید پس از ساخت TCP Proxy دستی وارد شوند.
- `PUBLIC_TCP_HOST` و `PUBLIC_TCP_PORT` برای تولید لینک هستند؛ پورت واقعی داخلی Listener همچنان `MTG_PORT` است.
- Health check برنامه، زنده بودن HTTP API را بررسی می‌کند. Railway پس از Deploy به‌طور پیوسته سلامت را پایش نمی‌کند؛ این محدودیت Healthcheck خود Railway است.
- مصرف CPU/حافظه در صفحه مربوط به پردازه/میزبان کانتینر است و آمار ترافیک MTProto یا مصرف کاربران نیست.

## Deploy روی Railway

1. این مخزن را به GitHub Push کنید یا پوشه پروژه را در محیط Build متصل کنید.
2. در Railway یک Project بسازید و Deploy from GitHub Repo را انتخاب کنید. Builder از `Dockerfile` استفاده می‌کند.
3. در Variables این مقادیر را وارد کنید:
   - `ADMIN_PASSWORD`: رمز تصادفی قوی (حداقل ۱۲ نویسه).
   - `MTG_PORT=3128`
   - `DATA_DIR=/data`
   - `AUTO_START_MTG=true`
4. در Settings > Volumes یک Volume بسازید و آن را روی `/data` Mount کنید. بدون Volume، دیتابیس و Secret با حذف کانتینر از بین می‌روند.
5. در Settings > Networking > Public Networking یک HTTP Domain بسازید تا پنل در دسترس باشد. Railway مقدار `PORT` را تزریق می‌کند؛ آن را دستی override نکنید.
6. در همان بخش TCP Proxy را برای پورت داخلی `3128` فعال کنید. Railway یک hostname و public port به شکل `xxxx.proxy.rlwy.net:NNNNN` می‌دهد.
7. مقدار hostname را بدون پورت در `PUBLIC_TCP_HOST` و عدد public port را در `PUBLIC_TCP_PORT` قرار دهید. سپس Redeploy کنید.
8. پنل را با HTTP Domain باز کنید و با `ADMIN_PASSWORD` وارد شوید.
9. در صفحه پروکسی، لینک Telegram و QR را بررسی کنید. برای تست نهایی، از یک شبکه بیرونی Telegram را با لینک ساخته‌شده متصل کنید.

### تفکیک پورت‌ها

| متغیر | کاربرد |
|---|---|
| `PORT` | HTTP پنل؛ توسط Railway تزریق می‌شود |
| `MTG_PORT` | پورت داخلی Listener موتور mtg؛ پیش‌فرض 3128 |
| `PUBLIC_TCP_HOST` | hostname عمومی که Railway برای TCP Proxy داده |
| `PUBLIC_TCP_PORT` | پورت عمومی TCP Proxy اختصاص‌داده‌شده توسط Railway |

لینک تلگرام باید از `PUBLIC_TCP_HOST:PUBLIC_TCP_PORT` ساخته شود؛ هرگز دامنه HTTP پنل یا `MTG_PORT` داخلی را به‌عنوان endpoint عمومی قرار ندهید.

## اجرای محلی با Docker

```bash
cp .env.example .env
# مقادیر امن را در .env تنظیم کنید
docker build -t master-iranfa .
docker run --rm -p 3000:3000 -p 3128:3128 \
  -v "$PWD/data:/data" --env-file .env master-iranfa
```

برای دسترسی مستقیم محلی، `PUBLIC_TCP_HOST` را روی IP/DNS قابل دسترس و `PUBLIC_TCP_PORT` را روی پورت NAT/فورواردشده تنظیم کنید. صرفاً باز بودن localhost به معنای دسترسی عمومی نیست.

## اجرای توسعه

نیازمند Node.js 20+ و باینری mtg سازگار با سیستم‌عامل است.

```bash
npm install
npm run dev       # Vite UI روی 5173 و API proxy به 3000
# در ترمینال دوم:
ADMIN_PASSWORD='use-a-strong-password' MTG_BIN=/path/to/mtg PORT=3000 npm start
```

برای build فرانت‌اند: `npm run build`. سپس `npm start` را اجرا کنید.

## Environment Variables

| نام | پیش‌فرض | توضیح |
|---|---:|---|
| `ADMIN_PASSWORD` | خالی | رمز اولیه مدیر؛ اگر تنظیم نشود ورود غیرفعال است |
| `PORT` | 3000 | پورت HTTP پنل |
| `MTG_PORT` | 3128 | پورت داخلی TCP موتور |
| `PUBLIC_TCP_HOST` | خالی | hostname عمومی TCP Proxy Railway |
| `PUBLIC_TCP_PORT` | خالی | پورت عمومی TCP Proxy Railway |
| `DATA_DIR` | `./data` | محل SQLite و تنظیمات موتور؛ روی Railway برابر `/data` |
| `MTG_BIN` | `/usr/local/bin/mtg` | مسیر باینری mtg |
| `AUTO_START_MTG` | `true` | شروع خودکار موتور هنگام Boot |
| `NODE_ENV` | — | در Railway برابر `production` تنظیم می‌شود |

## پشتیبان‌گیری و امنیت

- فایل backup حاوی Secret است؛ آن را در مخزن عمومی یا پیام‌رسان منتشر نکنید.
- تغییر Secret، لینک‌های قبلی را باطل می‌کند.
- رمز اولیه فقط در اولین Boot به هش bcrypt تبدیل می‌شود؛ پس از آن تغییر رمز از صفحه امنیت انجام می‌شود.
- برای بازیابی کامل، Volume را نیز Backup کنید؛ JSON export صرفاً رکورد پیکربندی پروکسی را نگه می‌دارد.
- پنل را پشت HTTPS Domain قرار دهید. در production کوکی نشست Secure است.
- از قرار دادن `ADMIN_PASSWORD` در Git یا سورس خودداری کنید.

## تست و وضعیت تضمین

`npm run check` و `npm run build` برای بررسی TypeScript و ساخت فرانت‌اند در محیط توسعه در نظر گرفته شده‌اند. اجرای موفق mtg و اتصال Telegram نهایی به داشتن دسترسی شبکه، باینری معماری صحیح، Volume و TCP Proxy واقعی Railway وابسته است. در محیط ساخت ZIP، یک سرویس Railway واقعی یا تخصیص TCP Proxy در اختیار نبود؛ بنابراین Deploy Railway، اتصال بیرونی تلگرام و عملکرد شبکه‌ای mtg ادعا نمی‌شوند که تست شده‌اند.

## مستندات مرجع

- mtg README و CLI: https://github.com/9seconds/mtg
- Railway TCP Proxy: https://docs.railway.com/networking/tcp-proxy
- Railway Healthchecks: https://docs.railway.com/deployments/healthchecks
