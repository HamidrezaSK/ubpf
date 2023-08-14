; ModuleID = 'ip_dst.c'
source_filename = "ip_dst.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nofree nosync nounwind uwtable
define dso_local i64 @is_dst_one_one_one_one(i8* nocapture noundef readonly %0) local_unnamed_addr #0 {
  %2 = getelementptr inbounds i8, i8* %0, i64 8
  %3 = bitcast i8* %2 to i16*
  %4 = load i16, i16* %3, align 4, !tbaa.struct !5
  %5 = getelementptr inbounds i8, i8* %0, i64 10
  %6 = bitcast i8* %5 to i16*
  %7 = load i16, i16* %6, align 2, !tbaa.struct !9
  %8 = getelementptr inbounds i8, i8* %0, i64 12
  %9 = bitcast i8* %8 to i16*
  %10 = load i16, i16* %9, align 4, !tbaa.struct !10
  %11 = getelementptr inbounds i8, i8* %0, i64 14
  %12 = bitcast i8* %11 to i16*
  %13 = load i16, i16* %12, align 2, !tbaa.struct !11
  %14 = getelementptr inbounds i8, i8* %0, i64 16
  %15 = bitcast i8* %14 to i16*
  %16 = load i16, i16* %15, align 4, !tbaa.struct !12
  %17 = getelementptr inbounds i8, i8* %0, i64 18
  %18 = bitcast i8* %17 to i16*
  %19 = load i16, i16* %18, align 2, !tbaa.struct !13
  %20 = getelementptr inbounds i8, i8* %0, i64 20
  %21 = bitcast i8* %20 to i16*
  %22 = load i16, i16* %21, align 4, !tbaa.struct !14
  %23 = getelementptr inbounds i8, i8* %0, i64 22
  %24 = bitcast i8* %23 to i16*
  %25 = load i16, i16* %24, align 2, !tbaa.struct !15
  %26 = insertelement <4 x i16> poison, i16 %4, i64 0
  %27 = shufflevector <4 x i16> %26, <4 x i16> poison, <4 x i32> zeroinitializer
  %28 = icmp eq <4 x i16> %27, <i16 4384, i16 288, i16 1574, i16 810>
  %29 = insertelement <4 x i16> poison, i16 %7, i64 0
  %30 = shufflevector <4 x i16> %29, <4 x i16> poison, <4 x i32> zeroinitializer
  %31 = icmp eq <4 x i16> %30, <i16 -18675, i16 -18419, i16 40, i16 -32728>
  %32 = select <4 x i1> %28, <4 x i1> %31, <4 x i1> zeroinitializer
  %33 = insertelement <4 x i16> poison, i16 %10, i64 0
  %34 = shufflevector <4 x i16> %33, <4 x i16> poison, <4 x i32> zeroinitializer
  %35 = icmp eq <4 x i16> %34, <i16 -19579, i16 -23675, i16 8194, i16 6898>
  %36 = select <4 x i1> %32, <4 x i1> %35, <4 x i1> zeroinitializer
  %37 = insertelement <4 x i16> poison, i16 %13, i64 0
  %38 = shufflevector <4 x i16> %37, <4 x i16> poison, <4 x i32> zeroinitializer
  %39 = icmp eq <4 x i16> %38, <i16 128, i16 7, i16 256, i16 -32000>
  %40 = select <4 x i1> %36, <4 x i1> %39, <4 x i1> zeroinitializer
  %41 = insertelement <4 x i16> poison, i16 %16, i64 0
  %42 = shufflevector <4 x i16> %41, <4 x i16> poison, <4 x i32> zeroinitializer
  %43 = icmp eq <4 x i16> %42, <i16 8528, i16 9, i16 18434, i16 -12550>
  %44 = select <4 x i1> %40, <4 x i1> %43, <4 x i1> zeroinitializer
  %45 = insertelement <4 x i16> poison, i16 %19, i64 0
  %46 = shufflevector <4 x i16> %45, <4 x i16> poison, <4 x i32> zeroinitializer
  %47 = icmp eq <4 x i16> %46, <i16 11914, i16 7818, i16 -27880, i16 2992>
  %48 = select <4 x i1> %44, <4 x i1> %47, <4 x i1> zeroinitializer
  %49 = insertelement <4 x i16> poison, i16 %22, i64 0
  %50 = shufflevector <4 x i16> %49, <4 x i16> poison, <4 x i32> zeroinitializer
  %51 = icmp eq <4 x i16> %50, <i16 28675, i16 28691, i16 -14299, i16 24579>
  %52 = select <4 x i1> %48, <4 x i1> %51, <4 x i1> zeroinitializer
  %53 = insertelement <4 x i16> poison, i16 %25, i64 0
  %54 = shufflevector <4 x i16> %53, <4 x i16> poison, <4 x i32> zeroinitializer
  %55 = icmp eq <4 x i16> %54, <i16 13427, i16 13330, i16 17945, i16 -8667>
  %56 = select <4 x i1> %52, <4 x i1> %55, <4 x i1> zeroinitializer
  %57 = bitcast <4 x i1> %56 to i4
  %58 = call i4 @llvm.ctpop.i4(i4 %57), !range !16
  %59 = zext i4 %58 to i64
  ret i64 %59
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i4 @llvm.ctpop.i4(i4) #1

attributes #0 = { nofree nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }

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
!9 = !{i64 0, i64 14, !6, i64 0, i64 14, !6, i64 0, i64 14, !6, i64 14, i64 16, !6, i64 14, i64 16, !6, i64 14, i64 16, !6}
!10 = !{i64 0, i64 12, !6, i64 0, i64 12, !6, i64 0, i64 12, !6, i64 12, i64 16, !6, i64 12, i64 16, !6, i64 12, i64 16, !6}
!11 = !{i64 0, i64 10, !6, i64 0, i64 10, !6, i64 0, i64 10, !6, i64 10, i64 16, !6, i64 10, i64 16, !6, i64 10, i64 16, !6}
!12 = !{i64 0, i64 8, !6, i64 0, i64 8, !6, i64 0, i64 8, !6, i64 8, i64 16, !6, i64 8, i64 16, !6, i64 8, i64 16, !6}
!13 = !{i64 0, i64 6, !6, i64 0, i64 6, !6, i64 0, i64 6, !6, i64 6, i64 16, !6, i64 6, i64 16, !6, i64 6, i64 16, !6}
!14 = !{i64 0, i64 4, !6, i64 0, i64 4, !6, i64 0, i64 4, !6, i64 4, i64 16, !6, i64 4, i64 16, !6, i64 4, i64 16, !6}
!15 = !{i64 0, i64 2, !6, i64 0, i64 2, !6, i64 0, i64 2, !6, i64 2, i64 16, !6, i64 2, i64 16, !6, i64 2, i64 16, !6}
!16 = !{i4 0, i4 5}
