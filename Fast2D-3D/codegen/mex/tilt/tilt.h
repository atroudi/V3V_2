/*
 * tilt.h
 *
 * Code generation for function 'tilt'
 *
 */

#ifndef __TILT_H__
#define __TILT_H__

/* Include files */
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "mwmathutil.h"
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "blas.h"
#include "rtwtypes.h"
#include "tilt_types.h"

/* Function Declarations */
extern void tilt(const emlrtStack *sp, const emxArray_uint8_T *image, real_T
                 max_disp, emxArray_uint8_T *stereo);

#endif

/* End of code generation (tilt.h) */
