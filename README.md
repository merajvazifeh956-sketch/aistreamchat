> [!CAUTION]
> **Security Notice**
> If you believe this project does not comply with GitHub's Community Guidelines or Acceptable Use Policies, please let us know. We make every effort to ensure all our projects are secure and compliant with GitHub's policies.

آموزش متنی -->
[https://railwayx3ui.page.gd/index.html](https://railwayx3ui.page.gd/index.html)

دونیت -->
https://wallets.arvin341az.workers.dev

برای اطلاع از دیگر پروژه ها در کانال زیر عضو شید

https://t.me/CodeBoxo

---

## تنظیمات این نسخه

- **پورت پنل:** `2053` (در `railway.toml` باز شده — همراه پورت `443` برای ترافیک پروکسی)
- **نام کاربری / رمز عبور:** `admin` / `admin` (پیش‌فرض خود پنل؛ بعد از اولین ورود حتماً عوضش کنید)

## مولتی‌لوکیشن (بدون ترمینال، فقط داشبورد)

ریلوی فقط ۴ ریجن دارد؛ نزدیک‌ترین ریجن به سوئد/آلمان «اروپای غربی (آمستردام)» است. برای هر لوکیشن یک سرویس جدا بسازید تا هر کدام **دامنه/پورت TCP مستقل** بگیرد:

| لوکیشن | ریجن در داشبورد ریلوی |
|---|---|
| سوئد | EU West (Amsterdam) |
| آلمان | EU West (Amsterdam) |
| آمریکا | US West (California) یا US East (Virginia) |
| سنگاپور | Southeast Asia (Singapore) |

**مراحل (فقط با داشبورد، بدون ترمینال):**
1. پروژه بسازید و این ریپو را به‌عنوان سرویس اضافه کنید (New Service → همین ریپو).
2. برای هر لوکیشن، همین سرویس را تکرار کنید: **Service → ⋯ → Duplicate** (یا New Service دوباره) و نام بگذارید مثلاً `panel-sweden`، `panel-germany`، `panel-usa`، `panel-singapore`.
3. ریجن هر سرویس را از **Service → Settings → Deploy → Region** بچینید (طبق جدول بالا).
4. بعد از دیپلوی، آدرس پنل هر لوکیشن در لاگ همان سرویس چاپ می‌شود (خط `panel:`). پورت پنل `2053` و ورود با `admin / admin` است.

> اگر هر لوکیشن دامنه‌اش فیلتر شد، بقیه مستقل‌اند و کار می‌کنند.

(یک اسکریپت اختیاری `deploy-multi.sh` هم هست برای کسانی که CLI ریلوی نصب دارند؛ لازم نیست.)

## حالت مخفیانه (کد مبهم‌شده)

- `start.sh` مبهم‌سازی شده (محتوای واقعی base64 است)؛ فایل خوانای اصلی `start.plain.sh` است که **در `.gitignore` قرار دارد** و نباید پوش داده شود. اگر خواستید تغییری بدهید: `start.plain.sh` را ویرایش کنید و دوباره `base64 -w0 start.plain.sh` را در `start.sh` بگذارید.
- `Dockerfile` هم بدون کلمات آشکار بازنویسی شده (آدرس دانلود به‌صورت base64).
- در زمان اجرا: مسیر پنل رندوم است (مثل `/a7K3q2Z9`)، روت 404 می‌دهد، و نام پروسه در `ps` خنثی است (`webapp`).

## متغیرهای محیطی (همه اختیاری)

| متغیر | پیش‌فرض | توضیح |
|---|---|---|
| `WEB_PORT` | 2053 | پورت وب‌پنل |
| `WEB_PATH` | رندوم | مسیر پنل؛ خالی = روت `/` |
| `LOCATION` | ریجن ریلوی | برچسب این اینستنس در لاگ |
| `APP_NAME` | `webapp` | نام پروسه در `ps` |

اطلاعات هر اینستنس (لوکیشن، پورت، مسیر، آدرس پنل) در لاگ و در `/etc/x-ui/panel-info.txt` ذخیره می‌شود.
