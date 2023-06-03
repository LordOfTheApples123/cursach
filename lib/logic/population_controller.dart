import 'dart:io';
import 'dart:math';

import 'package:cursa4/logic/population.dart';

import 'bot.dart';

class PopulationController {
  PopulationController(
    int size, {
    this.mutationChance = 0.3,
    this.mutationRatio = 0.3,
    this.mutationScaleBorder = 1.5,
    this.mutationDecrease = 0.01,
    this.decreaseMutation = false,
    this.monkeyMode = true,
  })  : population = Population(size),
        _rouletteSums = List.generate(size, (index) => -1);

  final Population population;
  double mutationChance;
  double mutationRatio;
  double mutationScaleBorder;
  double mutationDecrease;
  bool decreaseMutation;
  bool monkeyMode;
  final List<double> _rouletteSums;

  int currGen = 1;

  void evolve() {
    currGen++;
    select();
    if (decreaseMutation) {
      decMutation();
    }
    reset();
  }

  void select() {
    population.calcFitness();
    population.bots.sort(
        (b, a) => a.fitness.compareTo(b.fitness)); //sort most fit to least fit

    List<Bot> offsprings = [];

    int offset = (population.size / 2).ceil();

    _calculateFitnessSums();
    print("gen: $currGen");
    for (Bot bot in population.bots) {
      print(bot.fitness.toString());
      print(bot.survived.toString());
    }

    ///select and crossover
    for (int i = offset; i < population.size; i++) {
      // Bot parent1 = _rouletteSelection();
      // Bot parent2 = _rouletteSelection();

      Bot parent1 = population.bots[Random().nextInt(6)];
      Bot parent2 = population.bots[Random().nextInt(6)];

      while (population.bots.indexOf(parent2) ==
          population.bots.indexOf(parent1)) {
        // parent2 = _rouletteSelection();
        parent2 = population.bots[Random().nextInt(6)];
      }

      // Bot offspring = _crossover(parent1, parent2);
      Bot offspring = _SEX(parent1, parent2);

      ///mutate
      if (Random().nextDouble() < mutationChance) {
        if (monkeyMode) {
          if (Random().nextBool()) {
            safeMutate(offspring);
          } else {
            monkeyMutate(offspring);
          }
        } else {
          mutate(offspring);
        }
      }

      offspring.brain.init();

      offsprings.add(offspring);
    }

    for (int i = offset; i < population.size; i++) {
      population.bots[i] = offsprings[i - offset];
    }
  }

  Bot _rouletteSelection() {
    double rouleteRoll = Random().nextDouble();
    for (int i = 0; i < population.size; i++) {
      if (rouleteRoll <= _rouletteSums[i]) {
        return population.bots[i];
      }
    }
    return population.bots[population.bots.length - 1];
  }

  Bot _crossover(Bot daddy, Bot mommy) {
    List<int> numbers = List.generate(24, (index) => index);
    numbers.shuffle();

    ///indexes 0-19 - dad indexes, 20-39 mom indexes

    Bot child = new Bot(0, 0);

    ///dad weights and biases
    for (int i = 0; i < 16; i++) {
      if (numbers[i] ~/ 16 < 1) {
        child.brain.biases1to2[numbers[i]] = daddy.brain.biases1to2[numbers[i]];
        for (int j = 0; j < 24; j++) {
          child.brain.weights1to2[numbers[i]][j] =
              daddy.brain.weights1to2[numbers[i]][j];
        }
      } else {
        child.brain.biases2toOutput[numbers[i] % 16] =
            daddy.brain.biases2toOutput[numbers[i] % 16];
        for (int j = 0; j < 8; j++) {
          child.brain.weights2toOutput[numbers[i] % 16][j] =
              daddy.brain.weights2toOutput[numbers[i] % 16][j];
        }
      }
    }

    ///mom weights and biases
    for (int i = 16; i < 24; i++) {
      if (numbers[i] ~/ 16 < 1) {
        child.brain.biases1to2[numbers[i]] = mommy.brain.biases1to2[numbers[i]];
        for (int j = 0; j < 24; j++) {
          child.brain.weights1to2[numbers[i]][j] =
              mommy.brain.weights1to2[numbers[i]][j];
        }
      } else {
        child.brain.biases2toOutput[numbers[i] % 16] =
            mommy.brain.biases2toOutput[numbers[i] % 16];
        for (int j = 0; j < 8; j++) {
          child.brain.weights2toOutput[numbers[i] % 16][j] =
              mommy.brain.weights2toOutput[numbers[i] % 16][j];
        }
      }
    }
    return child;
  }

  void mutate(Bot offspring) {
    int inputNeuronsCount = offspring.brain.inputNeurons;
    int outputNeuronsCount = offspring.brain.outputNeurons;

    ///weights mutations
    for (int i = 0;
        i < inputNeuronsCount * outputNeuronsCount * mutationRatio;
        i++) {
      if (Random().nextInt(3) <= 1) {
        offspring.brain.weights1to2[Random().nextInt(16)]
                [Random().nextInt(24)] *=
            Random().nextInt(100) * 2 * mutationScaleBorder / 100 -
                mutationScaleBorder;
      } else {
        offspring.brain.weights2toOutput[Random().nextInt(8)]
                [Random().nextInt(16)] *=
            Random().nextInt(100) * 2 * mutationScaleBorder / 100 -
                mutationScaleBorder;
      }
    }

    ///biases mutation
    for (int i = 0; i < 24 * mutationRatio.ceil(); i++) {
      if (Random().nextInt(3) <= 1) {
        offspring.brain.biases1to2[Random().nextInt(16)] *=
            Random().nextInt(100) * 2 * mutationScaleBorder / 100 -
                mutationScaleBorder;
      } else {
        offspring.brain.biases2toOutput[Random().nextInt(8)] *=
            Random().nextInt(100) * 2 * mutationScaleBorder / 100 -
                mutationScaleBorder;
      }
    }
  }

  void _calculateFitnessSums() {
    double fitnessSum =
        population.bots.fold(0, (sum, element) => sum + element.fitness);
    _rouletteSums[0] = population.bots[0].fitness / fitnessSum;
    for (int i = 1; i < population.bots.length; i++) {
      _rouletteSums[i] =
          _rouletteSums[i - 1] + population.bots[i].fitness / fitnessSum;
    }
  }

  void reset() {
    population.activateBots();
  }

  void decMutation() {
    if (mutationChance > 0.05) {
      mutationChance -= mutationDecrease;
    }
    if (mutationRatio > 0.05) {
      mutationRatio -= mutationDecrease;
    }
  }

  void safeMutate(Bot offspring) {
    double tmp = mutationRatio;
    double scaleTmp = mutationScaleBorder;
    mutationScaleBorder = 1.2;
    mutationRatio = 0.05;
    // mutate(offspring);
    directMutate(offspring);
    mutationRatio = tmp;
    mutationScaleBorder = scaleTmp;
  }

  void monkeyMutate(Bot offspring) {
    double scaleTmp = mutationScaleBorder;
    mutationScaleBorder = 2;
    double tmp = mutationRatio;
    mutationRatio = 0.5;
    // mutate(offspring);
    directMutate(offspring);
    mutationRatio = tmp;
    mutationScaleBorder = scaleTmp;
  }

  void directMutate(Bot offspring) {
    ///weights mutations
    for (int i = 0;
        i <
            offspring.brain.inputNeurons *
                offspring.brain.outputNeurons *
                mutationRatio;
        i++) {
      offspring.brain.weightsToOutput[
                  Random().nextInt(offspring.brain.outputNeurons)]
              [Random().nextInt(offspring.brain.inputNeurons)] *=
          Random().nextInt(100) * 2 * mutationScaleBorder / 100 -
              mutationScaleBorder;
    }

    ///biases mutation
    for (int i = 0;
        i < offspring.brain.outputNeurons * mutationRatio.ceil();
        i++) {
      offspring.brain.biasesToOutput[
              Random().nextInt(offspring.brain.outputNeurons)] *=
          Random().nextInt(100) * 2 * mutationScaleBorder / 100 -
              mutationScaleBorder;
    }
  }

  Bot _SEX(Bot daddy, Bot mommy) {
    List<int> numbers =
        List.generate(daddy.brain.outputNeurons, (index) => index);
    numbers.shuffle();

    ///indexes 0-19 - dad indexes, 20-39 mom indexes

    Bot child = new Bot(0, 0);

    ///dad weights and biases
    for (int i = 0; i < daddy.brain.outputNeurons ~/ 2; i++) {
      child.brain.biasesToOutput[numbers[i]] =
          daddy.brain.biasesToOutput[numbers[i]];
      for (int j = 0; j < 4; j++) {
        child.brain.weightsToOutput[numbers[i]][j] =
            daddy.brain.weightsToOutput[numbers[i]][j];
      }
    }

    ///mom weights and biases
    for (int i = daddy.brain.outputNeurons ~/ 2;
        i < daddy.brain.outputNeurons;
        i++) {
      child.brain.biasesToOutput[numbers[i]] =
          mommy.brain.biasesToOutput[numbers[i]];
      for (int j = 0; j < 24; j++) {
        child.brain.weightsToOutput[numbers[i]][j] =
            mommy.brain.weightsToOutput[numbers[i]][j];
      }
    }
    return child;
  }
}
