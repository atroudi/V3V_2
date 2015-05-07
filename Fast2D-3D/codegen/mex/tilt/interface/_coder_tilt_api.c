/*
 * _coder_tilt_api.c
 *
 * Code generation for function '_coder_tilt_api'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "tilt.h"
#include "_coder_tilt_api.h"
#include "tilt_emxutil.h"

/* Variable Definitions */
static emlrtRTEInfo d_emlrtRTEI = { 1, 1, "_coder_tilt_api", "" };

/* Function Declarations */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, emxArray_uint8_T *y);
static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *max_disp,
  const char_T *identifier);
static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static void e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, emxArray_uint8_T *ret);
static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *image, const
  char_T *identifier, emxArray_uint8_T *y);
static const mxArray *emlrt_marshallOut(const emxArray_uint8_T *u);
static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId);

/* Function Definitions */
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, emxArray_uint8_T *y)
{
  e_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *max_disp,
  const char_T *identifier)
{
  real_T y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  y = d_emlrt_marshallIn(sp, emlrtAlias(max_disp), &thisId);
  emlrtDestroyArray(&max_disp);
  return y;
}

static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = f_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void e_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, emxArray_uint8_T *ret)
{
  int32_T iv3[3];
  boolean_T bv0[3];
  int32_T i;
  static const int16_T iv4[3] = { 1080, 960, 3 };

  static const boolean_T bv1[3] = { true, true, false };

  int32_T iv5[3];
  for (i = 0; i < 3; i++) {
    iv3[i] = iv4[i];
    bv0[i] = bv1[i];
  }

  emlrtCheckVsBuiltInR2012b(sp, msgId, src, "uint8", false, 3U, iv3, bv0, iv5);
  ret->size[0] = iv5[0];
  ret->size[1] = iv5[1];
  ret->size[2] = iv5[2];
  ret->allocatedSize = ret->size[0] * ret->size[1] * ret->size[2];
  ret->data = (uint8_T *)mxGetData(src);
  ret->canFreeData = false;
  emlrtDestroyArray(&src);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *image, const
  char_T *identifier, emxArray_uint8_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  b_emlrt_marshallIn(sp, emlrtAlias(image), &thisId, y);
  emlrtDestroyArray(&image);
}

static const mxArray *emlrt_marshallOut(const emxArray_uint8_T *u)
{
  const mxArray *y;
  static const int32_T iv2[3] = { 0, 0, 0 };

  const mxArray *m0;
  y = NULL;
  m0 = emlrtCreateNumericArray(3, iv2, mxUINT8_CLASS, mxREAL);
  mxSetData((mxArray *)m0, (void *)u->data);
  emlrtSetDimensions((mxArray *)m0, u->size, 3);
  emlrtAssign(&y, m0);
  return y;
}

static real_T f_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId)
{
  real_T ret;
  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 0U, 0);
  ret = *(real_T *)mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

void tilt_api(const mxArray * const prhs[2], const mxArray *plhs[1])
{
  emxArray_uint8_T *image;
  emxArray_uint8_T *stereo;
  real_T max_disp;
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  emxInit_uint8_T(&st, &image, 3, &d_emlrtRTEI, true);
  emxInit_uint8_T(&st, &stereo, 3, &d_emlrtRTEI, true);

  /* Marshall function inputs */
  emlrt_marshallIn(&st, emlrtAlias(prhs[0]), "image", image);
  max_disp = c_emlrt_marshallIn(&st, emlrtAliasP(prhs[1]), "max_disp");

  /* Invoke the target function */
  tilt(&st, image, max_disp, stereo);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(stereo);
  stereo->canFreeData = false;
  emxFree_uint8_T(&stereo);
  image->canFreeData = false;
  emxFree_uint8_T(&image);
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

/* End of code generation (_coder_tilt_api.c) */
