import 'dart:math';

import 'cell.dart';
import 'enum/cell_content.dart';
import 'enum/direction.dart';

class NeuralNetwork {

  int inputNeurons;
  int normalNeurons;
  int outputNeurons;
  final List<double> input;
  final List<double> normalizationLayer;
  final List<double> output;
///weights from j neuron prev layer to i neuron next layer
  final List<List<double>> weights1to2;
  final List<double> biases1to2;

  final List<List<double>> weightsToOutput;
  final List<double> biasesToOutput;

  final List<List<double>> weights2toOutput;
  final List<double> biases2toOutput;

  void provideInput(List<double> list) {
    for (int i = 0; i < list.length; i++) {
      input[i] = list[i];
    }
  }


  NeuralNetwork({int inputCount = 25, int normalCount = 16, int outputCount = 8}):
      inputNeurons = inputCount,
  normalNeurons = normalCount,
  outputNeurons = outputCount,
        weights1to2 = List.generate(normalCount,
                (index) => List.generate(inputCount, (index) => Random().nextInt(10) / 100 - 0.2)),
        biases1to2 =
        List.generate(normalCount, (index) => Random().nextInt(10) / 100 - 0.2),
        weights2toOutput =
        List.generate(outputCount, (index) => List.generate(normalCount, (index) => Random().nextInt(10) / 100 - 0.2)),
        biases2toOutput =
        List.generate(outputCount, (index) =>  Random().nextInt(10) / 100 - 0.2),
  weightsToOutput = List.generate(outputCount, (index) => List.generate(inputCount, (index) => Random().nextInt(10) / 100 - 0.2)),
  biasesToOutput = List.generate(outputCount, (index) => Random().nextInt(10) / 100 - 0.2),
  input = List.generate(inputCount, (index) => 0),
  normalizationLayer = List.generate(normalCount, (index) => 0),
  output =  List.generate(outputCount, (index) => 0);


  void init(){
    List<int> indexes= [6,7,8,11,12,15,16,17];
    for(int j = 0; j < outputNeurons; j++) {
      for(int index in indexes){
        weightsToOutput[j][index] *=2;

      }

    }


  }

  void _normalize() {
    double sum;
    for (int i = 0; i < weights1to2.length; i++) {
      sum = 0;
      for (int j = 0; j < weights1to2[0].length; j++) {
        sum += input[j] * weights1to2[i][j];
      }
      sum += biases1to2[i];
      normalizationLayer[i] = _sigmoid(sum);
    }
  }

  void _normalizeOutput() {
    double sum;
    for (int i = 0; i < weights2toOutput.length; i++) {
      sum = 0;
      for (int j = 0; j < weights2toOutput[0].length; j++) {
        sum += normalizationLayer[j] * weights2toOutput[i][j];
      }
      sum += biases2toOutput[i];
      output[i] = _sigmoid(sum);
    }
  }

  double _sigmoid(double sum) {
    return 1 / (1 + exp(-sum));
  }

  _direct(){
    double sum;
    for (int i = 0; i < weightsToOutput.length; i++) {
      sum = 0;
      for (int j = 0; j < weightsToOutput[0].length; j++) {
        sum += input[j] * weightsToOutput[i][j];
      }
      sum += biasesToOutput[i];
      output[i] = _sigmoid(sum);
    }
  }

  Direction getDirection() {
    // _normalize();
    // _normalizeOutput();
    _direct();

    double maxNeuron = output.reduce(max);
    int indexMax = output.indexOf(maxNeuron);
    // int indexMax = Random().nextInt(8);
    switch (indexMax) {
      case 0:
        return Direction.u;
      case 1:
        return Direction.ur;
      case 2:
        return Direction.r;
      case 3:
        return Direction.dr;
      case 4:
        return Direction.d;
      case 5:
        return Direction.dl;
      case 6:
        return Direction.l;
      case 7:
        return Direction.ul;
      default:
        print("wtf");
        return Direction.u;
    }
  }
}
