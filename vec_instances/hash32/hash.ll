; ModuleID = 'hash.c'
source_filename = "hash.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree nosync nounwind uwtable willreturn
define dso_local i64 @hash(i8* nocapture noundef readonly %0) local_unnamed_addr #0 {
  %2 = getelementptr inbounds i8, i8* %0, i64 8
  %3 = bitcast i8* %2 to i32*
  %4 = load i32, i32* %3, align 4, !tbaa.struct !5
  %5 = getelementptr inbounds i8, i8* %0, i64 12
  %6 = bitcast i8* %5 to i32*
  %7 = load i32, i32* %6, align 4, !tbaa.struct !9
  %8 = getelementptr inbounds i8, i8* %0, i64 16
  %9 = bitcast i8* %8 to i32*
  %10 = load i32, i32* %9, align 4, !tbaa.struct !10
  %11 = getelementptr inbounds i8, i8* %0, i64 20
  %12 = bitcast i8* %11 to i32*
  %13 = load i32, i32* %12, align 4, !tbaa.struct !11
  %14 = trunc i32 %4 to i16
  %15 = tail call i16 @llvm.bswap.i16(i16 %14) #2
  %16 = zext i16 %15 to i64
  %17 = trunc i32 %7 to i16
  %18 = tail call i16 @llvm.bswap.i16(i16 %17) #2
  %19 = zext i16 %18 to i64
  %20 = add nuw nsw i64 %19, %16
  %21 = trunc i32 %10 to i16
  %22 = tail call i16 @llvm.bswap.i16(i16 %21) #2
  %23 = zext i16 %22 to i64
  %24 = add nuw nsw i64 %20, %23
  %25 = trunc i32 %13 to i16
  %26 = tail call i16 @llvm.bswap.i16(i16 %25) #2
  %27 = zext i16 %26 to i64
  %28 = add nuw nsw i64 %24, %27
  %29 = mul nuw nsw i64 %28, 31
  ret i64 %29
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i16 @llvm.bswap.i16(i16) #1

attributes #0 = { mustprogress nofree nosync nounwind uwtable willreturn "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!5 = !{i64 0, i64 16, !6, i64 0, i64 16, !6, i64 0, i64 16, !6, i64 16, i64 16, !6, i64 16, i64 16, !6, i64 16, i64 16, !6}
!6 = !{!7, !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = !{i64 0, i64 12, !6, i64 0, i64 12, !6, i64 0, i64 12, !6, i64 12, i64 16, !6, i64 12, i64 16, !6, i64 12, i64 16, !6}
!10 = !{i64 0, i64 8, !6, i64 0, i64 8, !6, i64 0, i64 8, !6, i64 8, i64 16, !6, i64 8, i64 16, !6, i64 8, i64 16, !6}
!11 = !{i64 0, i64 4, !6, i64 0, i64 4, !6, i64 0, i64 4, !6, i64 4, i64 16, !6, i64 4, i64 16, !6, i64 4, i64 16, !6}
