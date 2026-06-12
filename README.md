## Clone Project

```bash
git clone <repository-url>
cd DEMO_DB_FLUTTER
```

---

## Setup Database

Mở MySQL Workbench và chạy:

```text
database/init.sql
```

File này sẽ tạo:

- Database: `flutter_demo_db`
- Table: `products`
- Sample data

---

## Setup Backend

Đi vào thư mục API:

```bash
cd shop_demo_api
```

Cài dependencies:

```bash
npm install
```

Tạo file `.env` từ `.env.example`

```bash
cp .env.example .env
```

Cập nhật thông tin MySQL trong `.env`:

```env
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=flutter_demo_db
```

Chạy API:

```bash
npm run dev
```

API sẽ chạy tại:

```text
http://localhost:3000
```

Kiểm tra:

```text
http://localhost:3000/api/products
```

---

## Setup Flutter

Mở terminal mới:

```bash
cd shop_demo_flutter
```

Cài dependencies:

```bash
flutter pub get
```

Chạy ứng dụng:

```bash
flutter run
```

Nếu sử dụng Android Emulator:

```text
http://10.0.2.2:3000/api/products
```

Nếu sử dụng Flutter Web:

```text
http://localhost:3000/api/products
```

---

## Run Project

### Terminal 1

```bash
cd shop_demo_api
npm run dev
```

### Terminal 2

```bash
cd shop_demo_flutter
flutter run
```

Backend và Flutter phải chạy cùng lúc.
