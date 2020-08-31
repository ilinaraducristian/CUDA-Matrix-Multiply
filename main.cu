#include <iostream>
#include <math.h>

using namespace std;

void print3DArray(float ***a, int n) {
  for(int i=0;i<n;i++) {
    for(int j=0;j<n;j++) {
      for(int k=0;k<n;k++) {
        cout<<a[i][j][k]<<' ';
      }
      cout<<endl;
    }
    cout<<endl<<endl<<endl;
  }
}

void print2DArray(float **a, int n) {
  for(int i=0;i<n;i++) {
    for(int j=0;j<n;j++) {
      cout<<a[i][j]<<' ';
    }
    cout<<endl;
  }
}

__global__ void multiply(float ***a, float ***b, int n) {

  int k = threadIdx.x+blockIdx.x;
  int j = threadIdx.y+blockIdx.y;
  int i = threadIdx.z+blockIdx.z;

  if(i<n && j<n && k<n) {
    a[i][j][k] = a[0][j][i] * b[0][i][k];
  }

}

__global__ void add(float ***a, int n) {

  int k = threadIdx.x+blockIdx.x;
  int j = threadIdx.y+blockIdx.y;
  int i = threadIdx.z+blockIdx.z;

  if(i<n && j<n && k<n) {
    for(int l=1;l<n;l++) {
      a[0][j][k]+=a[l][j][k];
    }
  }

}

int main(void) {
  int n = 100;
  // int blockSize = 256;
  // int blocks = (N + blockSize - 1) / blockSize;

  float ***a, ***b;
  cudaMallocManaged(&a, n*sizeof(float**));
  cudaMallocManaged(&b, n*sizeof(float**));

  for(int i=0;i<n;i++) {
    cudaMallocManaged(&(a[i]), n*sizeof(float*));
    cudaMallocManaged(&(b[i]), n*sizeof(float*));
  }

  for(int i=0;i<n;i++) {
      for(int j=0;j<n;j++) {
        cudaMallocManaged(&(a[i][j]), n*sizeof(float));
        cudaMallocManaged(&(b[i][j]), n*sizeof(float));
      }
  }

  for(int i=0;i<n;i++) {
    for(int j=0;j<n;j++) {
      a[0][i][j] = rand() % 4 + 1;
      b[0][i][j] = rand() % 4 + 1;
    }
  }

  // Print A, B

  cout<<"A:"<<endl;

  print2DArray(*a, n);

  cout<<"B:"<<endl;

  print2DArray(*b, n);

  // Multiply matrices
  multiply<<< 10, dim3(10, 10, 10) >>>(a, b, n);

  // Set number of threads and blocks

//   int blockSize = 1024;
//   int numBlocks = sqrt(n / blockSize);

//   addSquareMatrices<<< 1, dim3(32, 32, 32) >>>(x, y, n);

  cudaDeviceSynchronize();

  add<<< 1, dim3(10, 10, 10) >>>(a, n);

  cudaDeviceSynchronize();

  // Print A*B

  cout<<"A*B:"<<endl;

  print2DArray(*a, n);

  cout<<"done"<<endl;

  cudaFree(a);
  cudaFree(b);
  
  return 0;
}