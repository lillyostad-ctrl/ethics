**وضعیت:** پروژه‌ی Supabase با نام ethics-boardroom ساخته شده، اسکیما اجرا شده و config.js پر است. فقط مراحل ۶ و ۷ مانده.

# اتاق تصمیم اخلاق بالینی (نسخه‌ی Supabase)

۱. در supabase.com یک پروژه بسازید.
۲. SQL Editor را باز کنید و محتوای `schema.sql` را اجرا کنید.
۳. Project Settings > API: مقدار `Project URL` و `anon public key` را در `config.js` بگذارید.
۴. Authentication > Providers > Email روشن باشد. اگر نمی‌خواهید تأیید ایمیل لازم باشد، Confirm email را خاموش کنید.
۵. Authentication > URL Configuration: آدرس سایت خود را در Site URL بگذارید.
۶. پوشه را روی هر میزبان استاتیک (Netlify، Vercel، GitHub Pages، Cloudflare Pages) آپلود کنید. نیازی به build نیست.
۷. برای ادمین شدن: بعد از ثبت‌نام، در Table Editor یک ردیف در `admins` با `user_id` خودتان اضافه کنید.

نکته‌ها
- فقط anon key در `config.js` باشد. service_role را هرگز در فرانت‌اند نگذارید.
- RLS فعال است: هر کاربر فقط داده‌ی خودش را می‌بیند. ادمین همه را می‌خواند.
- جدول‌ها: profiles، progress (وضعیت کامل بازی و برگه‌ی ۹ گام)، attempts (هر پاسخ، برای گزارش‌گیری)، admins.
- این نسخه را روی Claude.ai نمی‌شود اجرا کرد، چون آنجا اتصال به سرور بیرونی بسته است.
