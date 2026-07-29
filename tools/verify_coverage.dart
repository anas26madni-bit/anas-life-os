import 'dart:io';

const double minimumCoverage = 90;

void main(List<String> arguments) {
  if (arguments.length != 1) {
    stderr.writeln('Usage: dart run tools/verify_coverage.dart <lcov.info>');
    exitCode = 64;
    return;
  }

  final input = File(arguments.single);
  if (!input.existsSync()) {
    stderr.writeln('Coverage file does not exist: ${input.path}');
    exitCode = 66;
    return;
  }

  var includeCurrentRecord = false;
  var linesFound = 0;
  var linesHit = 0;
  var branchesFound = 0;
  var branchesHit = 0;

  for (final line in input.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      final source = line.substring(3).replaceAll(r'\', '/');
      includeCurrentRecord = _isBusinessSource(source) && !_isGenerated(source);
    } else if (includeCurrentRecord && line.startsWith('LF:')) {
      linesFound += int.parse(line.substring(3));
    } else if (includeCurrentRecord && line.startsWith('LH:')) {
      linesHit += int.parse(line.substring(3));
    } else if (includeCurrentRecord && line.startsWith('BRF:')) {
      branchesFound += int.parse(line.substring(4));
    } else if (includeCurrentRecord && line.startsWith('BRH:')) {
      branchesHit += int.parse(line.substring(4));
    }
  }

  final lineCoverage = _percentage(linesHit, linesFound);
  final branchCoverage = _percentage(branchesHit, branchesFound);
  stdout.writeln('Line coverage: ${lineCoverage.toStringAsFixed(2)}%');
  stdout.writeln('Branch coverage: ${branchCoverage.toStringAsFixed(2)}%');

  if (lineCoverage < minimumCoverage || branchCoverage < minimumCoverage) {
    stderr.writeln(
      'Coverage must be at least $minimumCoverage% for lines and branches.',
    );
    exitCode = 1;
  }
}

bool _isGenerated(String path) {
  return path.endsWith('.g.dart') ||
      path.contains('/l10n/app_localizations') ||
      path.endsWith('.freezed.dart');
}

bool _isBusinessSource(String path) {
  return path.contains('/domain/') ||
      path.contains('/usecases/') ||
      path.contains('/business/');
}

double _percentage(int hit, int found) {
  return found == 0 ? 100 : (hit / found) * 100;
}
