# ML Kit text recognition only ships with the Latin script recognizer
# (google_mlkit_text_recognition). The base TextRecognizer class references
# the optional Chinese/Devanagari/Japanese/Korean recognizer classes, which
# are not present since those script-specific packages aren't included as
# dependencies. Keep/ignore them so R8 doesn't fail with "missing classes".
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
