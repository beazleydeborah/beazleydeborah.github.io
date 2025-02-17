# Overheads App

flutter clean
flutter pub get
flutter build web

cd build/web
git init
git add .
git commit -m "Deploy 4"
git remote add origin https://github.com/beazleydeborah/beazleydeborah.github.io.git
git push -u --force origin master