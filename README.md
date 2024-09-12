# Check In

Die Grundidee der App ist, dass man die Anwesenheit von Kursteilnehmer durch z.B. einen Studentenausweis überprüfen kann. 
Zunächst kann man dafür verschiedene Kurse anlegen. Zu den Kursen kann man dann Teilnehmer hinzufügen. Um später die Anwesenheit der Teilnehmer mit dem Studentenausweis überprüfen zu können, muss man den Ausweis auch beim Erstellen des Teilnehmers scannen. 
Wenn alle Teilnehmer in den Kurs eingetragen sind, kann man dann den entsprechenden Kurs auswählen und die Teilnehmer können ihren Studentenausweis an das Handy halten. Dieses liest dann den NFC-Tag aus und kreuzt die Personen als anwesend an. Um alle Funktionen einmal zu sehen habe ich ein kurzes Video erstellt, in dem ich durch die App gehe: https://youtu.be/16oOrMLm-Cg

# So kann man die App ausprobieren

## 1. APK herunterladen
   Der einfachste Weg ist, sich die APK runterzuladen und auf seinem Handy auszuführen.
   Hier kann man sich die APK herunterladen: https://www.upload-apk.com/5YZu4518BNWeNf6 
   
   Das geht aber leider nur für Android Handys.
## 2. APK auf PC laufen
###   Ihr könnt die App auch auf eurem PC laufen lassen. Da euer PC vermutlich keinen NFC-Scanner hat, könnt ihr dann aber die Funktion, dass man Studentenausweise scannen kann leider nicht benutzen :(
###   a) Die APK könnt ihr euch über diesen Link herunterladen: https://www.upload-apk.com/5YZu4518BNWeNf6
###   b) Dann ladet euch BlueStacks runter.

   Entweder hier: https://www.bluestacks.com/de/bluestacks-x.html
   
   Oder hier noch eine Anleitung für Mac: https://support.bluestacks.com/hc/de/articles/360000736632-Wie-kann-ich-BlueStacks-auf-macOS-installieren-und-ausf%C3%BChren
   
###   c) Jetzt könnt ihr innerhalb von BlueStacks die APK hochladen und die App ausprobieren:)
   Wie das geht ist hier beschrieben: https://support.bluestacks.com/hc/de/articles/11054623928717-So-installierst-du-eine-APK-auf-BlueStacks-X
   
###   Beachtet, dass aus irgendeinem Grund einen kleinen Bug beim dem Scann-Button gibt. Der Scann-Button ändert nicht die Farbe und das Icon. Vermutlich liegt es am fehlenden NFC-Scanner.
   ![Recording-2024-09-12-195226-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/c5468142-004e-432b-b384-c8c312a26a9d)
## 3. App auf Handy oder Emulator laufen
###   a) Lade Android Studio runter: https://developer.android.com/studio?hl=de
###   b) Jetzt kannst du das Repository herunterladen:
   ![image](https://github.com/user-attachments/assets/4c5f1159-61dc-4ed4-a7f8-801ed33c128b)
   ![image](https://github.com/user-attachments/assets/1026d829-ec07-4900-a3c0-bbf17c238897)
###  c) Entpacke dann die Zip-Datei.
###   d) Jetzt kannst du in Android Studio den Ordner, und somit das Projekt öffnen:
   ![image](https://github.com/user-attachments/assets/c44ac678-6a37-478d-a516-db323a3ca2a8)
   oder:
   ![image](https://github.com/user-attachments/assets/bc432b57-d6c1-4238-8567-71e77395b01d)

###   e) Wenn du selbst ein Android Gerät hast, kannst du es einfach mit deinem PC verbinden und die App darauf starten. Dazu hier zwei Anleitungen:
   - https://jbtronic.medium.com/how-to-run-your-flutter-app-on-physical-android-device-248e7fb91404
   - https://docs.flutter.dev/platform-integration/android/install-android/install-android-from-windows

###   f) Sonst kannst du die App auch auf einem Emulator laufen lassen. Hier eine Anleitung dazu:
   - https://docs.flutter.dev/platform-integration/android/install-android/install-android-from-windows

# So könnt findet ihr durch den Code
   Hier einmal erklärt, wie ihr den relevanten Code findet, wenn ihr euch einmal genauer anschauen wollt, wie die App aufgebaut ist. 

   Der Code ist unterteilt in die "main", die einzelnen Seiten und die Datenbank.

   So findet ihr die "main": lib > main.dart
   
   So findet ihr die Seiten: lib > pages > ... hier sind dann die vier Unterseiten
   
   So findet ihr die Datenbank: lib > sql > sql_helper.dart

   Außerdem sind vielleicht noch die Packages interessant, die ich verwendet habe. Die findet ihr direkt in der "pubspec.ymal" unter dem Abschnitt "dependencies: flutter: ..."


