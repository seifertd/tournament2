#include <stdlib.h>
#include <math.h>
#include <stdio.h>

typedef struct _ScoreObj {
  int score, max;
} ScoreObj;

int ffi_games_in_round(int n_teams, int r) {
  return (n_teams / 2) / pow(2, r);
}

int ffi_score_of(int round, int winner, int loser) {
  return pow(2, round);
}

void ffi_score(int n_teams, int rounds, int *bracket, int *picks, ScoreObj *retVal) {
  retVal->score = 0;
  retVal->max = 0;
  int bracket_index = 0;
  for (int round = 0; round < rounds; ++round) {
    int games = ffi_games_in_round(n_teams, round);
    for (int j = 0; j < games; ++j) {
      int b_result = bracket[bracket_index];
      int b_winner = bracket[bracket_index+1];
      int b_loser = bracket[bracket_index+2];
      int p_result = picks[bracket_index];
      int p_winner = picks[bracket_index+1];
      int p_loser = picks[bracket_index+2];
      if (b_result != -1 && b_result == p_result) {
        retVal->score = retVal->score + ffi_score_of(round, b_winner, b_loser);
      }
      if (b_result == -1) {
        retVal->max = retVal->max + ffi_score_of(round, p_winner, p_loser);
      } else {
        retVal->max = retVal->max + ffi_score_of(round, b_winner, b_loser);
      }
      bracket_index = bracket_index + 3;
    }
  }
  //printf("EXT: SCORE: %d MAX: %d\n", retVal->score, retVal->max);
  return;
}
