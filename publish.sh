echo "-- Compressing --"
rm -rf console.hx.zip
zip -Z store -r console.hx.zip . -x "*.DS_Store" -x "publish.sh" -x "__*" -x "_built/*" -x ".*" -x "*.zip"

echo "-- Submitting --"
haxelib submit console.hx.zip