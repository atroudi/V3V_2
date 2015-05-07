/*
 * tilt.c
 *
 * Code generation for function 'tilt'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "tilt.h"
#include "tilt_emxutil.h"
#include "tilt_data.h"

/* Variable Definitions */
static emlrtRTEInfo emlrtRTEI = { 1, 18, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m" };

static emlrtRTEInfo b_emlrtRTEI = { 8, 1, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m" };

static emlrtRTEInfo c_emlrtRTEI = { 9, 1, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m" };

static emlrtECInfo emlrtECI = { 1, 28, 8, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m" };

static emlrtECInfo b_emlrtECI = { -1, 24, 5, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m" };

static emlrtBCInfo emlrtBCI = { -1, -1, 24, 15, "right", "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 0 };

static emlrtDCInfo emlrtDCI = { 24, 15, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 1 };

static emlrtBCInfo b_emlrtBCI = { -1, -1, 24, 11, "right", "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 0 };

static emlrtECInfo c_emlrtECI = { -1, 23, 5, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m" };

static emlrtBCInfo c_emlrtBCI = { -1, -1, 23, 14, "left", "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 0 };

static emlrtDCInfo b_emlrtDCI = { 23, 14, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 1 };

static emlrtBCInfo d_emlrtBCI = { -1, -1, 23, 10, "left", "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 0 };

static emlrtBCInfo e_emlrtBCI = { -1, -1, 24, 63, "image", "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 0 };

static emlrtDCInfo c_emlrtDCI = { 24, 63, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 1 };

static emlrtBCInfo f_emlrtBCI = { -1, -1, 24, 59, "image", "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 0 };

static emlrtBCInfo g_emlrtBCI = { -1, -1, 23, 62, "image", "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 0 };

static emlrtDCInfo d_emlrtDCI = { 23, 62, "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 1 };

static emlrtBCInfo h_emlrtBCI = { -1, -1, 23, 58, "image", "tilt",
  "/Users/kiana/Desktop/2D_3D/Fast2D-3D/tilt.m", 0 };

/* Function Definitions */
void tilt(const emlrtStack *sp, const emxArray_uint8_T *image, real_T max_disp,
          emxArray_uint8_T *stereo)
{
  emxArray_uint8_T *left;
  int32_T image_idx_0;
  int32_T i0;
  int32_T loop_ub;
  emxArray_uint8_T *right;
  real_T disp_per_row;
  int32_T row;
  real_T x;
  int32_T i1;
  int32_T i2;
  int32_T tmp_data[960];
  int32_T iv0[3];
  int32_T image_size[3];
  int32_T b_image[3];
  int32_T b_tmp_data[961];
  int32_T iv1[3];
  int32_T b_image_size[3];
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_uint8_T(sp, &left, 3, &b_emlrtRTEI, true);

  /* image=gpuArray(image); */
  image_idx_0 = image->size[0];
  i0 = left->size[0] * left->size[1] * left->size[2];
  left->size[0] = image_idx_0;
  emxEnsureCapacity(sp, (emxArray__common *)left, i0, (int32_T)sizeof(uint8_T),
                    &emlrtRTEI);
  image_idx_0 = image->size[1];
  i0 = left->size[0] * left->size[1] * left->size[2];
  left->size[1] = image_idx_0;
  left->size[2] = 3;
  emxEnsureCapacity(sp, (emxArray__common *)left, i0, (int32_T)sizeof(uint8_T),
                    &emlrtRTEI);
  loop_ub = image->size[0] * image->size[1] * 3;
  for (i0 = 0; i0 < loop_ub; i0++) {
    left->data[i0] = 127;
  }

  emxInit_uint8_T(sp, &right, 3, &c_emlrtRTEI, true);
  image_idx_0 = image->size[0];
  i0 = right->size[0] * right->size[1] * right->size[2];
  right->size[0] = image_idx_0;
  emxEnsureCapacity(sp, (emxArray__common *)right, i0, (int32_T)sizeof(uint8_T),
                    &emlrtRTEI);
  image_idx_0 = image->size[1];
  i0 = right->size[0] * right->size[1] * right->size[2];
  right->size[1] = image_idx_0;
  right->size[2] = 3;
  emxEnsureCapacity(sp, (emxArray__common *)right, i0, (int32_T)sizeof(uint8_T),
                    &emlrtRTEI);
  loop_ub = image->size[0] * image->size[1] * 3;
  for (i0 = 0; i0 < loop_ub; i0++) {
    right->data[i0] = 127;
  }

  disp_per_row = max_disp / ((real_T)image->size[0] - 1.0);
  row = 0;
  while (row <= image->size[0] - 1) {
    /*     %{ */
    /*     for col=1:(W-round(disp_per_row*(H-row))) */
    /*          */
    /*         left(row,col)=image(row,round(disp_per_row*(H-row))+col); */
    /*         right(row,round(disp_per_row*(H-row))+col)=image(row,col); */
    /*     end */
    /*     %} */
    x = muDoubleScalarRound(disp_per_row * (real_T)((image->size[0] - row) - 1));
    if (x + 1.0 > image->size[1]) {
      i0 = 0;
      i1 = -1;
    } else {
      i0 = image->size[1];
      i1 = (int32_T)emlrtIntegerCheckFastR2012b(x + 1.0, &d_emlrtDCI, sp);
      i0 = emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &g_emlrtBCI, sp) - 1;
      i1 = image->size[1];
      i2 = image->size[1];
      i1 = emlrtDynamicBoundsCheckFastR2012b(i2, 1, i1, &g_emlrtBCI, sp) - 1;
    }

    x = (real_T)left->size[1] - muDoubleScalarRound(disp_per_row * (real_T)
      ((image->size[0] - row) - 1));
    if (1.0 > x) {
      loop_ub = 0;
    } else {
      i2 = left->size[1];
      emlrtDynamicBoundsCheckFastR2012b(1, 1, i2, &c_emlrtBCI, sp);
      i2 = left->size[1];
      image_idx_0 = (int32_T)emlrtIntegerCheckFastR2012b(x, &b_emlrtDCI, sp);
      loop_ub = emlrtDynamicBoundsCheckFastR2012b(image_idx_0, 1, i2,
        &c_emlrtBCI, sp);
    }

    i2 = left->size[0];
    image_idx_0 = row + 1;
    emlrtDynamicBoundsCheckFastR2012b(image_idx_0, 1, i2, &d_emlrtBCI, sp);
    for (i2 = 0; i2 < loop_ub; i2++) {
      tmp_data[i2] = i2;
    }

    i2 = image->size[0];
    image_idx_0 = row + 1;
    emlrtDynamicBoundsCheckFastR2012b(image_idx_0, 1, i2, &h_emlrtBCI, sp);
    iv0[0] = 1;
    iv0[1] = loop_ub;
    iv0[2] = 3;
    image_size[0] = 1;
    image_size[1] = (i1 - i0) + 1;
    image_size[2] = 3;
    for (i2 = 0; i2 < 3; i2++) {
      b_image[i2] = image_size[i2];
    }

    emlrtSubAssignSizeCheckR2012b(iv0, 3, b_image, 3, &c_emlrtECI, sp);
    for (i2 = 0; i2 < 3; i2++) {
      loop_ub = i1 - i0;
      for (image_idx_0 = 0; image_idx_0 <= loop_ub; image_idx_0++) {
        left->data[(row + left->size[0] * tmp_data[image_idx_0]) + left->size[0]
          * left->size[1] * i2] = image->data[(row + image->size[0] * (i0 +
          image_idx_0)) + image->size[0] * image->size[1] * i2];
      }
    }

    x = (real_T)image->size[1] - muDoubleScalarRound(disp_per_row * (real_T)
      ((image->size[0] - row) - 1));
    if (1.0 > x) {
      loop_ub = -1;
    } else {
      i0 = image->size[1];
      emlrtDynamicBoundsCheckFastR2012b(1, 1, i0, &e_emlrtBCI, sp);
      i0 = image->size[1];
      i1 = (int32_T)emlrtIntegerCheckFastR2012b(x, &c_emlrtDCI, sp);
      loop_ub = emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &e_emlrtBCI, sp) -
        1;
    }

    x = muDoubleScalarRound(disp_per_row * (real_T)((image->size[0] - row) - 1));
    if (x + 1.0 > right->size[1]) {
      i0 = 0;
      i1 = 0;
    } else {
      i0 = right->size[1];
      i1 = (int32_T)emlrtIntegerCheckFastR2012b(x + 1.0, &emlrtDCI, sp);
      i0 = emlrtDynamicBoundsCheckFastR2012b(i1, 1, i0, &emlrtBCI, sp) - 1;
      i1 = right->size[1];
      i2 = right->size[1];
      i1 = emlrtDynamicBoundsCheckFastR2012b(i2, 1, i1, &emlrtBCI, sp);
    }

    i2 = right->size[0];
    image_idx_0 = row + 1;
    emlrtDynamicBoundsCheckFastR2012b(image_idx_0, 1, i2, &b_emlrtBCI, sp);
    image_idx_0 = i1 - i0;
    for (i2 = 0; i2 < image_idx_0; i2++) {
      b_tmp_data[i2] = i0 + i2;
    }

    i2 = image->size[0];
    image_idx_0 = row + 1;
    emlrtDynamicBoundsCheckFastR2012b(image_idx_0, 1, i2, &f_emlrtBCI, sp);
    iv1[0] = 1;
    iv1[1] = i1 - i0;
    iv1[2] = 3;
    b_image_size[0] = 1;
    b_image_size[1] = loop_ub + 1;
    b_image_size[2] = 3;
    for (i0 = 0; i0 < 3; i0++) {
      b_image[i0] = b_image_size[i0];
    }

    emlrtSubAssignSizeCheckR2012b(iv1, 3, b_image, 3, &b_emlrtECI, sp);
    for (i0 = 0; i0 < 3; i0++) {
      for (i1 = 0; i1 <= loop_ub; i1++) {
        right->data[(row + right->size[0] * b_tmp_data[i1]) + right->size[0] *
          right->size[1] * i0] = image->data[(row + image->size[0] * i1) +
          image->size[0] * image->size[1] * i0];
      }
    }

    row++;
    emlrtBreakCheckFastR2012b(emlrtBreakCheckR2012bFlagVar, sp);
  }

  i0 = left->size[0];
  i1 = right->size[0];
  emlrtDimSizeEqCheckFastR2012b(i0, i1, &emlrtECI, sp);
  i0 = stereo->size[0] * stereo->size[1] * stereo->size[2];
  stereo->size[0] = left->size[0];
  stereo->size[1] = left->size[1] + right->size[1];
  stereo->size[2] = 3;
  emxEnsureCapacity(sp, (emxArray__common *)stereo, i0, (int32_T)sizeof(uint8_T),
                    &emlrtRTEI);
  for (i0 = 0; i0 < 3; i0++) {
    loop_ub = left->size[1];
    for (i1 = 0; i1 < loop_ub; i1++) {
      image_idx_0 = left->size[0];
      for (i2 = 0; i2 < image_idx_0; i2++) {
        stereo->data[(i2 + stereo->size[0] * i1) + stereo->size[0] *
          stereo->size[1] * i0] = left->data[(i2 + left->size[0] * i1) +
          left->size[0] * left->size[1] * i0];
      }
    }
  }

  for (i0 = 0; i0 < 3; i0++) {
    loop_ub = right->size[1];
    for (i1 = 0; i1 < loop_ub; i1++) {
      image_idx_0 = right->size[0];
      for (i2 = 0; i2 < image_idx_0; i2++) {
        stereo->data[(i2 + stereo->size[0] * (i1 + left->size[1])) +
          stereo->size[0] * stereo->size[1] * i0] = right->data[(i2 +
          right->size[0] * i1) + right->size[0] * right->size[1] * i0];
      }
    }
  }

  emxFree_uint8_T(&right);
  emxFree_uint8_T(&left);

  /* stereo=gather(stereo); */
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (tilt.c) */
