پنل پروکسی مستر ایرانفا | MASTER IRANFA
POWERED BY MASTER IRANFA

راهنمای کامل فارسی در فایل README.md قرار دارد.

خلاصه استقرار Railway:
1) Dockerfile را Deploy کنید.
2) ADMIN_PASSWORD قوی، MTG_PORT=3128 و DATA_DIR=/data را تنظیم کنید.
3) یک Railway Volume روی /data متصل کنید.
4) برای HTTP یک Railway Domain بسازید.
5) در Settings > Networking یک TCP Proxy برای پورت داخلی 3128 بسازید.
6) hostname عمومی و public port خروجی Railway را به‌ترتیب در PUBLIC_TCP_HOST و PUBLIC_TCP_PORT قرار دهید.
7) Redeploy کنید و از صفحه پروکسی لینک اتصال تلگرام را بسازید.

موتور mtg در نسخه 2.3.0 pin شده است. این نسخه در هر سرویس فقط یک listener و Secret اصلی را مدیریت می‌کند. قابلیت کاربر اختصاصی، سهمیه ترافیک و آمار کاربران در mtg موجود نیست و در پنل جعل نشده است.

بدون ADMIN_PASSWORD ورود غیرفعال است. بدون Volume داده‌ها پایدار نمی‌مانند. بدون TCP Proxy عمومی، لینک اتصال تلگرام ساخته نمی‌شود.
