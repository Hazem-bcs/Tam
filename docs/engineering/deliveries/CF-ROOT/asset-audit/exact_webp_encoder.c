#include <stdio.h>
#include <stdlib.h>
#include <webp/encode.h>
int main(int argc, char** argv) {
  if (argc != 5) return 2;
  int w=atoi(argv[3]), h=atoi(argv[4]); size_t size=(size_t)w*h*4;
  unsigned char* rgba=malloc(size); FILE* in=fopen(argv[1],"rb");
  if (!in || !rgba || fread(rgba,1,size,in)!=size) return 3;
  fclose(in);
  WebPConfig config; WebPPicture pic; WebPMemoryWriter out;
  if (!WebPConfigInit(&config) || !WebPPictureInit(&pic)) return 4;
  config.lossless=1; config.quality=100; config.method=6; config.exact=1;
  pic.use_argb=1; pic.width=w; pic.height=h;
  if (!WebPPictureImportRGBA(&pic,rgba,w*4)) return 5;
  WebPMemoryWriterInit(&out); pic.writer=WebPMemoryWrite; pic.custom_ptr=&out;
  if (!WebPEncode(&config,&pic)) return 6;
  FILE* target=fopen(argv[2],"wb"); if (!target) return 7;
  int ok=fwrite(out.mem,1,out.size,target)==out.size; fclose(target);
  WebPMemoryWriterClear(&out); WebPPictureFree(&pic); free(rgba); return ok?0:8;
}
