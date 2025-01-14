﻿#include <math.h>
#include <iostream>
#include <cuda_runtime.h>
#include "device_launch_parameters.h"
#include "definedGPUFunctions.cuh";
#include "gpuMath.h";

__device__ __forceinline__ float sigmoidG(float x) {
    return 1.0 / (1.0 + exp(-x));
}

__device__ __forceinline__ float sigmoidPrimeG(float x) {
    float temp = sigmoidG(x);
    return temp * (1 - temp);
}

__global__ void sigmoid_kernelG(const float* __restrict__ src, float* __restrict__ dst, int len) {
    int stride = gridDim.x * blockDim.x;
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    for (int i = tid; i < len; i += stride) {
        dst[i] = sigmoidG(src[i]);
    }
}

__global__ void sigmoidPrime_kernelG(const float* __restrict src, float* __restrict__ dst, int len) {
    int stride = gridDim.x * blockDim.x;
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    for (int i = tid; i < len; i += stride) {
        dst[i] = sigmoidPrimeG(src[i]);
    }
}

__global__ void reLu_kernelG(const float* __restrict__ src, float* __restrict__ dst, int len) {
    int stride = gridDim.x * blockDim.x;
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    for (int i = tid; i < len; i += stride) {
        float tV = src[i];
        if (tV > 0) {
            dst[i] = tV;
        }
        else {
            dst[i] = 0;
        }
    }
}

__global__ void reLuPrime_kernelG(const float* __restrict__ src, float* __restrict__ dst, int len) {
    int stride = gridDim.x * blockDim.x;
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    for (int i = tid; i < len; i += stride) {
        float tV = src[i];
        if (tV > 0) {
            dst[i] = 1;
        }
        else {
            dst[i] = 0;
        }
    }
}

__global__ void addKernel(const float *a, const float *b, float *c, int len) {
    int stride = gridDim.x * blockDim.x;
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    for (int i = tid; i < len; i += stride) {
        c[i] = a[i] + b[i];
    }
}

__global__ void subKernel(const float* a, const float* b, float* c, int len) {
    int stride = gridDim.x * blockDim.x;
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    for (int i = tid; i < len; i += stride) {
        c[i] = a[i] - b[i];
    }
}

__global__ void multCompKernel(const float* a, const float* b, float* c, int len) {
    int stride = gridDim.x * blockDim.x;
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    for (int i = tid; i < len; i += stride) {
        c[i] = a[i] * b[i];
    }
}

__global__ void multScalarCompKernel(const float* a, float f, float* c, int len) {
    int stride = gridDim.x * blockDim.x;
    int tid = blockDim.x * blockIdx.x + threadIdx.x;
    for (int i = tid; i < len; i += stride) {
        c[i] = a[i] * f;
    }
}

void definedGPUFunctions::addMatCWiseGPUMem(float *a, float *b, float *c, int len) {
    dim3 dimBlock(256);
    int threadBlocks = (len + (dimBlock.x - 1)) / dimBlock.x;
    if (threadBlocks > 65520) threadBlocks = 65520;
    dim3 dimGrid(threadBlocks);
    addKernel<<<dimGrid, dimBlock >>>(a, b, c,len);
}
void definedGPUFunctions::subMatCWiseGPUMem(float *a, float *b, float *c, int len) {
    dim3 dimBlock(256);
    int threadBlocks = (len + (dimBlock.x - 1)) / dimBlock.x;
    if (threadBlocks > 65520) threadBlocks = 65520;
    dim3 dimGrid(threadBlocks);
    subKernel<<<dimGrid, dimBlock >>>(a, b, c,len);
}
void definedGPUFunctions::multCompCWiseGPUMem(float *a, float *b, float *c, int len) {
    dim3 dimBlock(256);
    int threadBlocks = (len + (dimBlock.x - 1)) / dimBlock.x;
    if (threadBlocks > 65520) threadBlocks = 65520;
    dim3 dimGrid(threadBlocks);
    multCompKernel<<<dimGrid, dimBlock >>>(a, b, c,len);
}
void definedGPUFunctions::multCompCWiseGPUMemScalar(float* a, float f, float* c, int len) {
    dim3 dimBlock(256);
    int threadBlocks = (len + (dimBlock.x - 1)) / dimBlock.x;
    if (threadBlocks > 65520) threadBlocks = 65520;
    dim3 dimGrid(threadBlocks);
    multScalarCompKernel<<<dimGrid, dimBlock >>>(a, f, c,len);
}
void definedGPUFunctions::sigmoidMatCWiseGPUMem(float* A, float* B, int len) {
    dim3 dimBlock(256);
    int threadBlocks = (len + (dimBlock.x - 1)) / dimBlock.x;
    if (threadBlocks > 65520) threadBlocks = 65520;
    dim3 dimGrid(threadBlocks);
    sigmoid_kernelG<<<dimGrid, dimBlock>>>(A, B, len);
}
void definedGPUFunctions::sigmoidPrimeMatCWiseGPUMem(float* A, float* B, int len) {
    dim3 dimBlock(256);
    int threadBlocks = (len + (dimBlock.x - 1)) / dimBlock.x;
    if (threadBlocks > 65520) threadBlocks = 65520;
    dim3 dimGrid(threadBlocks);
    sigmoidPrime_kernelG<<<dimGrid, dimBlock>>>(A, B, len);
}

void definedGPUFunctions::reLuMatCWiseGPUMem(float* A, float* B, int len) {
    dim3 dimBlock(256);
    int threadBlocks = (len + (dimBlock.x - 1)) / dimBlock.x;
    if (threadBlocks > 65520) threadBlocks = 65520;
    dim3 dimGrid(threadBlocks);
    reLu_kernelG << <dimGrid, dimBlock >> > (A, B, len);
}

void definedGPUFunctions::reLuPrimeMatCWiseGPUMem(float* A, float* B, int len) {
    dim3 dimBlock(256);
    int threadBlocks = (len + (dimBlock.x - 1)) / dimBlock.x;
    if (threadBlocks > 65520) threadBlocks = 65520;
    dim3 dimGrid(threadBlocks);
    reLuPrime_kernelG << <dimGrid, dimBlock >> > (A, B, len);
}

/*
int main() {
    //this main method tests the functionality of the sigmoid and sigmoidPrime computations on the GPU
    int m = 3;
    int n = 3;
    float* cpuA = (float*)malloc(sizeof(float) * m * n);
    float* cpuB = (float*)malloc(sizeof(float) * m * n);
    float* gpuA, * gpuB;
    cudaMalloc(&gpuA, sizeof(float) * m * n);
    cudaMalloc(&gpuB, sizeof(float) * m * n);
    gpuMath::blasOp::randMatCPUMem(cpuA, m, n);
    cudaMemcpy(gpuA, cpuA, sizeof(float) * m * n, cudaMemcpyHostToDevice);
    std::cout << "A=" << std::endl;
    gpuMath::blasOp::print_matrix(cpuA, m, n);
    definedGPUFunctions::sigmoidPrimeMatCWiseGPUMem(gpuA, gpuB, sizeof(float) * m * n);
    cudaMemcpy(cpuB, gpuB, sizeof(float) * m * n, cudaMemcpyDeviceToHost);
    std::cout << "B=" << std::endl;
    gpuMath::blasOp::print_matrix(cpuB, m, n);
}
*/