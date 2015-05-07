/*
 * tilt_initialize.c
 *
 * Code generation for function 'tilt_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "tilt.h"
#include "tilt_initialize.h"
#include "tilt_data.h"

/* Function Definitions */
void tilt_initialize(emlrtContext *aContext)
{
  emlrtStack st = { NULL, NULL, NULL };

  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, aContext, NULL, 1);
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (tilt_initialize.c) */
