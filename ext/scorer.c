#include <stdlib.h>
#include <math.h>
#include <stdio.h>

typedef struct _TeamObj {
  int index, seed;
} TeamObj;

typedef struct _ScoreObj {
  int score, max;
} ScoreObj;

struct _TeamObj NCAA_TEAMS[] = {
  {0,1}, {1, 16}, {2, 8}, {3, 9}, {4, 5}, {5, 12}, {6, 4}, {7, 13}, {8, 6}, {9, 11}, {10, 3}, {11, 14},
  {12, 7}, {13, 10}, {14, 2}, {15, 15}, {16, 1}, {17, 16}, {18, 8}, {19, 9}, {20, 5}, {21, 12}, {22, 4},
  {23, 13}, {24, 6}, {25, 11}, {26, 3}, {27, 14}, {28, 7}, {29, 10}, {30, 2}, {31, 15}, {32, 1}, {33, 16},
  {34, 8}, {35, 9}, {36, 5}, {37, 12}, {38, 4}, {39, 13}, {40, 6}, {41, 11}, {42, 3}, {43, 14}, {44, 7},
  {45, 10}, {46, 2}, {47, 15}, {48, 1}, {49, 16}, {50, 8}, {51, 9}, {52, 5}, {53, 12}, {54, 4}, {55, 13},
  {56, 6}, {57, 11}, {58, 3}, {59, 14}, {60, 7}, {61, 10}, {62, 2}, {63, 15}
};

int t2_games_in_round(int n_teams, int r) {
  return (n_teams / 2) / pow(2, r);
}

int t2_basic(int round, int winner, int loser) {
  static int roundScores[6] = {1,2,4,8,16,32};
  return roundScores[round];
}

int t2_josh_patashnik(int round, int winner, int loser) {
  static int multipliers[6] = {1,2,4,8,16,32};
  TeamObj winnerTeam = NCAA_TEAMS[winner];
  //printf("SCORING JOSH PATASHNIK: r:%d w:%d l:%d mult: %d winningTeam.seed: %d\n", round, winner, loser, multipliers[round], winnerTeam.seed);
  return multipliers[round] * winnerTeam.seed;
}

int t2_tweaked_josh_patashnik(int round, int winner, int loser) {
  static int multipliers[6] = {1,2,4,8,12,22};
  TeamObj winnerTeam = NCAA_TEAMS[winner];
  return multipliers[round] * winnerTeam.seed;
}

int t2_constant_value(int round, int winner, int loser) {
  return 1;
}

int t2_upset(int round, int winner, int loser) {
  static int per_round[6] = {3,5,11,19,30,40};
  TeamObj winnerTeam = NCAA_TEAMS[winner];
  return per_round[round] + winnerTeam.seed;
}

enum ScoringMethod {
  BASIC = 1,
  JOSH_PATASHNIK,
  TWEAKED_JOSH_PATASHNIK,
  UPSET,
  CONSTANT_VALUE
};

typedef int (*scoringMethodPtr)(int, int, int);
scoringMethodPtr t2_scoring_method_for(enum ScoringMethod scoringMethod) {
  switch(scoringMethod) {
    case BASIC:
      return t2_basic;
    case JOSH_PATASHNIK:
      return t2_josh_patashnik;
    case TWEAKED_JOSH_PATASHNIK:
      return t2_tweaked_josh_patashnik;
    case UPSET:
      return t2_upset;
    case CONSTANT_VALUE:
      return t2_constant_value;
  }
}

int t2_score_of(enum ScoringMethod scoringMethod, int round, int winner, int loser) {
  scoringMethodPtr scoringFunc = t2_scoring_method_for(scoringMethod);
  int score = (*scoringFunc)(round, winner, loser);
  //printf(" T2: method: %d round: %d winner: %d loser: %d score: %d\n", scoringMethod, round, winner, loser, score);
  return score;
}

void t2_score(int n_teams, int rounds, enum ScoringMethod scoringMethod, int *bracket, int *picks, ScoreObj *scoreObj) {
  scoreObj->score = 0;
  scoreObj->max = 0;
  int bracket_index = 0;
  int round, game;
  scoringMethodPtr scoringFunc = t2_scoring_method_for(scoringMethod);
  for (round = 0; round < rounds; ++round) {
    int games = t2_games_in_round(n_teams, round);
    for (game = 0; game < games; ++game) {
      int b_result = bracket[bracket_index];
      int b_winner = bracket[bracket_index+1];
      int b_loser = bracket[bracket_index+2];
      int p_result = picks[bracket_index];
      int p_winner = picks[bracket_index+1];
      int p_loser = picks[bracket_index+2];
      //printf("T2: t2_score: r:%d g:%d b_r:%d p_r:%d\n", round, game, b_result, p_result);
      if (b_result != -1 && b_result == p_result) {
        scoreObj->score = scoreObj->score + (*scoringFunc)(round, b_winner, b_loser);
      }
      if (b_result == -1) {
        scoreObj->max = scoreObj->max + (*scoringFunc)(round, p_winner, p_loser);
      } else {
        scoreObj->max = scoreObj->max + (*scoringFunc)(round, b_winner, b_loser);
      }
      bracket_index = bracket_index + 3;
    }
  }
  //printf("T2: SCORE: %d MAX: %d\n", scoreObj->score, scoreObj->max);
  return;
}
