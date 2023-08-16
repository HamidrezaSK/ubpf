; ModuleID = 'hash.c'
source_filename = "hash.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree nosync nounwind uwtable willreturn
define dso_local i64 @hash(i8* nocapture noundef readonly %0) local_unnamed_addr #0 {
  %2 = getelementptr inbounds i8, i8* %0, i64 8
  %3 = bitcast i8* %2 to <8 x i16>*
  %4 = load <8 x i16>, <8 x i16>* %3, align 4
  %5 = call <8 x i16> @llvm.bswap.v8i16(<8 x i16> %4)
  %6 = zext <8 x i16> %5 to <8 x i64>
  %7 = call i64 @llvm.vector.reduce.add.v8i64(<8 x i64> %6)
  %8 = mul nuw nsw i64 %7, 31
  ret i64 %8
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare <8 x i16> @llvm.bswap.v8i16(<8 x i16>) #1

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i64 @llvm.vector.reduce.add.v8i64(<8 x i64>) #2

attributes #0 = { mustprogress nofree nosync nounwind uwtable willreturn "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nofree nosync nounwind readnone willreturn }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
