import 'dart:io';

void main(List<String> args) async {
  print("\n");
  print("\t\t\tWelcome to Flutter Clener\n\n");

  final directory = getDirectory();

  if (isFlutterProject(directory.path)) {
    Directory.current = directory.path;
    await runFlutterClean();
  } else {
    final dirList = directory.listSync();

    for (var element in dirList) {
      if (element is Directory) {
        Directory.current = element.path;
        await runFlutterClean();
      }
    }
  }

  exit(0);
}

Future<void> deleteFlutterDirectory(Directory directory) async {
  if (isFlutterProject(directory.path)) {
    Directory.current = directory.path;
    await runFlutterClean();
  } else {
    final dirList = directory.listSync();

    for (var element in dirList) {
      if (element is Directory) {
        await deleteFlutterDirectory(element);
      }
    }
  }
}

// check  given path is flutter project
bool isFlutterProject(String path) {
  // Check if pubspec.yaml exists in the folder
  final pubspecFile = File('$path/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    return false;
  }

  // Check if 'lib' folder exists in the folder
  final libDir = Directory('$path/lib');
  if (!libDir.existsSync()) {
    return false;
  }

  // If all checks pass, consider it a Flutter project
  return true;
}

Directory getDirectory() {
  print("Please enter path where you want to clean flutter projects\n");

  stdout.write("path: ");
  final path = stdin.readLineSync()?.trim();
  print("");

  //check given path is valid or not
  if (path == null || !Directory(path).existsSync()) {
    print("path is not valid\n");
    return getDirectory();
  } else {
    return Directory(path);
  }
}

Future<bool> runFlutterClean() async {
  print("running ${Directory.current}");
  try {
    // Run the 'flutter clean' command using Process.run
    final result = await Process.start('flutter', ['clean']);

    result.stdout.listen((data) {
      print(String.fromCharCodes(data));
    });

    result.stderr.listen((data) {
      print('error: ${String.fromCharCodes(data)}');
    });

    // Wait for the process to complete
    final exitCode = await result.exitCode;
    print('Exit code: $exitCode');

    // Check the exit code to determine if the command was successful
    if (exitCode == 0) {
      print('Flutter clean successful for ${Directory.current}');
      return true;
    } else {
      print(
          'Flutter clean failed path: ${Directory.current} \n error: ${result.stderr}');
      return false;
    }
  } catch (e) {
    print('Error executing Flutter clean: $e');
    return false;
  }
}
