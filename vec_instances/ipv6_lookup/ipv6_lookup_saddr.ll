; ModuleID = 'ipv6_lookup_saddr.c'
source_filename = "ipv6_lookup_saddr.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.in6_addr = type { %union.anon }
%union.anon = type { [4 x i32] }

@lookups = dso_local local_unnamed_addr global [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }] [{ { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 } { { { [8 x i16] } } { { [8 x i16] } { [8 x i16] [i16 8209, i16 3511, i16 -31309, i16 -32768, i16 20513, i16 -30162, i16 880, i16 29492] } }, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, i16 0, i16 0, i16 0, i16 0, i8 0, i8 0 }, { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 } { { { [8 x i16] } } { { [8 x i16] } { [8 x i16] [i16 8193, i16 3512, i16 -31325, i16 1792, i16 2304, i16 -30178, i16 4976, i16 4660] } }, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, i16 0, i16 0, i16 0, i16 0, i8 0, i8 0 }, { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 } { { { [8 x i16] } } { { [8 x i16] } { [8 x i16] [i16 9734, i16 10240, i16 544, i16 1, i16 584, i16 6291, i16 9672, i16 6470] } }, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, i16 0, i16 0, i16 0, i16 0, i8 0, i8 0 }, { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 } { { { [8 x i16] } } { { [8 x i16] } { [8 x i16] [i16 10755, i16 10368, i16 -3558, i16 131, i16 -1330, i16 -20469, i16 864, i16 9694] } }, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, i16 0, i16 0, i16 0, i16 0, i8 0, i8 0 }], align 16

; Function Attrs: mustprogress nofree nosync nounwind uwtable willreturn
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
  %26 = tail call i16 @llvm.bswap.i16(i16 %4) #2
  %27 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 0), align 16, !tbaa !6
  %28 = icmp eq i16 %26, %27
  br i1 %28, label %29, label %57

29:                                               ; preds = %1
  %30 = tail call i16 @llvm.bswap.i16(i16 %7) #2
  %31 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 1), align 2, !tbaa !6
  %32 = icmp eq i16 %30, %31
  br i1 %32, label %33, label %57

33:                                               ; preds = %29
  %34 = tail call i16 @llvm.bswap.i16(i16 %10) #2
  %35 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 2), align 4, !tbaa !6
  %36 = icmp eq i16 %34, %35
  br i1 %36, label %37, label %57

37:                                               ; preds = %33
  %38 = tail call i16 @llvm.bswap.i16(i16 %13) #2
  %39 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 3), align 2, !tbaa !6
  %40 = icmp eq i16 %38, %39
  br i1 %40, label %41, label %57

41:                                               ; preds = %37
  %42 = tail call i16 @llvm.bswap.i16(i16 %16) #2
  %43 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 4), align 8, !tbaa !6
  %44 = icmp eq i16 %42, %43
  br i1 %44, label %45, label %57

45:                                               ; preds = %41
  %46 = tail call i16 @llvm.bswap.i16(i16 %19) #2
  %47 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 5), align 2, !tbaa !6
  %48 = icmp eq i16 %46, %47
  br i1 %48, label %49, label %57

49:                                               ; preds = %45
  %50 = tail call i16 @llvm.bswap.i16(i16 %22) #2
  %51 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 6), align 4, !tbaa !6
  %52 = icmp eq i16 %50, %51
  br i1 %52, label %53, label %57

53:                                               ; preds = %49
  %54 = tail call i16 @llvm.bswap.i16(i16 %25) #2
  %55 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 7), align 2, !tbaa !6
  %56 = icmp eq i16 %54, %55
  br i1 %56, label %58, label %57

57:                                               ; preds = %53, %49, %45, %41, %37, %33, %29, %1
  br label %58

58:                                               ; preds = %53, %57
  %59 = phi i64 [ 0, %57 ], [ 1, %53 ]
  %60 = load <8 x i16>, <8 x i16>* bitcast (i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 1, i32 0, i32 0, i32 0, i64 0) to <8 x i16>*), align 4
  %61 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 0), align 8, !tbaa !6
  %62 = icmp eq i16 %26, %61
  %63 = tail call i16 @llvm.bswap.i16(i16 %7) #2
  %64 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 1), align 2
  %65 = icmp eq i16 %63, %64
  %66 = select i1 %62, i1 %65, i1 false
  br i1 %66, label %67, label %91

67:                                               ; preds = %58
  %68 = tail call i16 @llvm.bswap.i16(i16 %10) #2
  %69 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 2), align 4, !tbaa !6
  %70 = icmp eq i16 %68, %69
  br i1 %70, label %71, label %91

71:                                               ; preds = %67
  %72 = tail call i16 @llvm.bswap.i16(i16 %13) #2
  %73 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 3), align 2, !tbaa !6
  %74 = icmp eq i16 %72, %73
  br i1 %74, label %75, label %91

75:                                               ; preds = %71
  %76 = tail call i16 @llvm.bswap.i16(i16 %16) #2
  %77 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 4), align 16, !tbaa !6
  %78 = icmp eq i16 %76, %77
  br i1 %78, label %79, label %91

79:                                               ; preds = %75
  %80 = tail call i16 @llvm.bswap.i16(i16 %19) #2
  %81 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 5), align 2, !tbaa !6
  %82 = icmp eq i16 %80, %81
  br i1 %82, label %83, label %91

83:                                               ; preds = %79
  %84 = tail call i16 @llvm.bswap.i16(i16 %22) #2
  %85 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 6), align 4, !tbaa !6
  %86 = icmp eq i16 %84, %85
  br i1 %86, label %87, label %91

87:                                               ; preds = %83
  %88 = tail call i16 @llvm.bswap.i16(i16 %25) #2
  %89 = load i16, i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 7), align 2, !tbaa !6
  %90 = icmp eq i16 %88, %89
  br i1 %90, label %98, label %91

91:                                               ; preds = %58, %87, %83, %79, %75, %71, %67
  %92 = tail call i16 @llvm.bswap.i16(i16 %10) #2
  %93 = tail call i16 @llvm.bswap.i16(i16 %13) #2
  %94 = tail call i16 @llvm.bswap.i16(i16 %16) #2
  %95 = tail call i16 @llvm.bswap.i16(i16 %19) #2
  %96 = tail call i16 @llvm.bswap.i16(i16 %22) #2
  %97 = tail call i16 @llvm.bswap.i16(i16 %25) #2
  br label %98

98:                                               ; preds = %87, %91
  %99 = phi i16 [ %88, %87 ], [ %97, %91 ]
  %100 = phi i16 [ %84, %87 ], [ %96, %91 ]
  %101 = phi i16 [ %80, %87 ], [ %95, %91 ]
  %102 = phi i16 [ %76, %87 ], [ %94, %91 ]
  %103 = phi i16 [ %72, %87 ], [ %93, %91 ]
  %104 = phi i16 [ %68, %87 ], [ %92, %91 ]
  %105 = phi i64 [ 1, %87 ], [ 0, %91 ]
  %106 = insertelement <8 x i16> poison, i16 %26, i64 0
  %107 = insertelement <8 x i16> %106, i16 %63, i64 1
  %108 = insertelement <8 x i16> %107, i16 %104, i64 2
  %109 = insertelement <8 x i16> %108, i16 %103, i64 3
  %110 = insertelement <8 x i16> %109, i16 %102, i64 4
  %111 = insertelement <8 x i16> %110, i16 %101, i64 5
  %112 = insertelement <8 x i16> %111, i16 %100, i64 6
  %113 = insertelement <8 x i16> %112, i16 %99, i64 7
  %114 = icmp eq <8 x i16> %113, %60
  %115 = freeze <8 x i1> %114
  %116 = bitcast <8 x i1> %115 to i8
  %117 = icmp eq i8 %116, -1
  %118 = zext i1 %117 to i64
  %119 = add nuw nsw i64 %59, %118
  %120 = add nuw nsw i64 %119, %105
  %121 = load <8 x i16>, <8 x i16>* bitcast (i16* getelementptr inbounds ([4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }], [4 x { { { [8 x i16] } }, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }]* @lookups, i64 0, i64 3, i32 0, i32 0, i32 0, i64 0) to <8 x i16>*), align 4
  %122 = icmp eq <8 x i16> %113, %121
  %123 = freeze <8 x i1> %122
  %124 = bitcast <8 x i1> %123 to i8
  %125 = icmp eq i8 %124, -1
  %126 = zext i1 %125 to i64
  %127 = add nuw nsw i64 %120, %126
  ret i64 %127
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
!9 = !{i64 0, i64 14, !6, i64 0, i64 14, !6, i64 0, i64 14, !6, i64 14, i64 16, !6, i64 14, i64 16, !6, i64 14, i64 16, !6}
!10 = !{i64 0, i64 12, !6, i64 0, i64 12, !6, i64 0, i64 12, !6, i64 12, i64 16, !6, i64 12, i64 16, !6, i64 12, i64 16, !6}
!11 = !{i64 0, i64 10, !6, i64 0, i64 10, !6, i64 0, i64 10, !6, i64 10, i64 16, !6, i64 10, i64 16, !6, i64 10, i64 16, !6}
!12 = !{i64 0, i64 8, !6, i64 0, i64 8, !6, i64 0, i64 8, !6, i64 8, i64 16, !6, i64 8, i64 16, !6, i64 8, i64 16, !6}
!13 = !{i64 0, i64 6, !6, i64 0, i64 6, !6, i64 0, i64 6, !6, i64 6, i64 16, !6, i64 6, i64 16, !6, i64 6, i64 16, !6}
!14 = !{i64 0, i64 4, !6, i64 0, i64 4, !6, i64 0, i64 4, !6, i64 4, i64 16, !6, i64 4, i64 16, !6, i64 4, i64 16, !6}
!15 = !{i64 0, i64 2, !6, i64 0, i64 2, !6, i64 0, i64 2, !6, i64 2, i64 16, !6, i64 2, i64 16, !6, i64 2, i64 16, !6}
