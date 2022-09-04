elm make src/Main.elm --output=build/bundle.js --optimize
cp -r ./build/* ../../modules/lexicon/web
