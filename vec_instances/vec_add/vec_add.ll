; ModuleID = 'vec_add.c'
source_filename = "vec_add.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nofree norecurse nosync nounwind uwtable
define dso_local void @vector_add(i32* nocapture noundef writeonly %0, i32* nocapture noundef readonly %1, i32* nocapture noundef readonly %2, i32 noundef %3) local_unnamed_addr #0 {
  %5 = icmp sgt i32 %3, 0
  br i1 %5, label %6, label %117

6:                                                ; preds = %4
  %7 = zext i32 %3 to i64
  %8 = icmp ult i32 %3, 8
  br i1 %8, label %96, label %9

9:                                                ; preds = %6
  %10 = getelementptr i32, i32* %0, i64 %7
  %11 = getelementptr i32, i32* %1, i64 %7
  %12 = getelementptr i32, i32* %2, i64 %7
  %13 = icmp ugt i32* %11, %0
  %14 = icmp ugt i32* %10, %1
  %15 = and i1 %13, %14
  %16 = icmp ugt i32* %12, %0
  %17 = icmp ugt i32* %10, %2
  %18 = and i1 %16, %17
  %19 = or i1 %15, %18
  br i1 %19, label %96, label %20

20:                                               ; preds = %9
  %21 = and i64 %7, 4294967288
  %22 = add nsw i64 %21, -8
  %23 = lshr exact i64 %22, 3
  %24 = add nuw nsw i64 %23, 1
  %25 = and i64 %24, 1
  %26 = icmp eq i64 %22, 0
  br i1 %26, label %72, label %27

27:                                               ; preds = %20
  %28 = and i64 %24, 4611686018427387902
  br label %29

29:                                               ; preds = %29, %27
  %30 = phi i64 [ 0, %27 ], [ %69, %29 ]
  %31 = phi i64 [ 0, %27 ], [ %70, %29 ]
  %32 = getelementptr inbounds i32, i32* %1, i64 %30
  %33 = bitcast i32* %32 to <4 x i32>*
  %34 = load <4 x i32>, <4 x i32>* %33, align 4, !tbaa !5, !alias.scope !9
  %35 = getelementptr inbounds i32, i32* %32, i64 4
  %36 = bitcast i32* %35 to <4 x i32>*
  %37 = load <4 x i32>, <4 x i32>* %36, align 4, !tbaa !5, !alias.scope !9
  %38 = getelementptr inbounds i32, i32* %2, i64 %30
  %39 = bitcast i32* %38 to <4 x i32>*
  %40 = load <4 x i32>, <4 x i32>* %39, align 4, !tbaa !5, !alias.scope !12
  %41 = getelementptr inbounds i32, i32* %38, i64 4
  %42 = bitcast i32* %41 to <4 x i32>*
  %43 = load <4 x i32>, <4 x i32>* %42, align 4, !tbaa !5, !alias.scope !12
  %44 = add <4 x i32> %40, %34
  %45 = add <4 x i32> %43, %37
  %46 = getelementptr inbounds i32, i32* %0, i64 %30
  %47 = bitcast i32* %46 to <4 x i32>*
  store <4 x i32> %44, <4 x i32>* %47, align 4, !tbaa !5, !alias.scope !14, !noalias !16
  %48 = getelementptr inbounds i32, i32* %46, i64 4
  %49 = bitcast i32* %48 to <4 x i32>*
  store <4 x i32> %45, <4 x i32>* %49, align 4, !tbaa !5, !alias.scope !14, !noalias !16
  %50 = or i64 %30, 8
  %51 = getelementptr inbounds i32, i32* %1, i64 %50
  %52 = bitcast i32* %51 to <4 x i32>*
  %53 = load <4 x i32>, <4 x i32>* %52, align 4, !tbaa !5, !alias.scope !9
  %54 = getelementptr inbounds i32, i32* %51, i64 4
  %55 = bitcast i32* %54 to <4 x i32>*
  %56 = load <4 x i32>, <4 x i32>* %55, align 4, !tbaa !5, !alias.scope !9
  %57 = getelementptr inbounds i32, i32* %2, i64 %50
  %58 = bitcast i32* %57 to <4 x i32>*
  %59 = load <4 x i32>, <4 x i32>* %58, align 4, !tbaa !5, !alias.scope !12
  %60 = getelementptr inbounds i32, i32* %57, i64 4
  %61 = bitcast i32* %60 to <4 x i32>*
  %62 = load <4 x i32>, <4 x i32>* %61, align 4, !tbaa !5, !alias.scope !12
  %63 = add <4 x i32> %59, %53
  %64 = add <4 x i32> %62, %56
  %65 = getelementptr inbounds i32, i32* %0, i64 %50
  %66 = bitcast i32* %65 to <4 x i32>*
  store <4 x i32> %63, <4 x i32>* %66, align 4, !tbaa !5, !alias.scope !14, !noalias !16
  %67 = getelementptr inbounds i32, i32* %65, i64 4
  %68 = bitcast i32* %67 to <4 x i32>*
  store <4 x i32> %64, <4 x i32>* %68, align 4, !tbaa !5, !alias.scope !14, !noalias !16
  %69 = add nuw i64 %30, 16
  %70 = add i64 %31, 2
  %71 = icmp eq i64 %70, %28
  br i1 %71, label %72, label %29, !llvm.loop !17

72:                                               ; preds = %29, %20
  %73 = phi i64 [ 0, %20 ], [ %69, %29 ]
  %74 = icmp eq i64 %25, 0
  br i1 %74, label %94, label %75

75:                                               ; preds = %72
  %76 = getelementptr inbounds i32, i32* %1, i64 %73
  %77 = bitcast i32* %76 to <4 x i32>*
  %78 = load <4 x i32>, <4 x i32>* %77, align 4, !tbaa !5, !alias.scope !9
  %79 = getelementptr inbounds i32, i32* %76, i64 4
  %80 = bitcast i32* %79 to <4 x i32>*
  %81 = load <4 x i32>, <4 x i32>* %80, align 4, !tbaa !5, !alias.scope !9
  %82 = getelementptr inbounds i32, i32* %2, i64 %73
  %83 = bitcast i32* %82 to <4 x i32>*
  %84 = load <4 x i32>, <4 x i32>* %83, align 4, !tbaa !5, !alias.scope !12
  %85 = getelementptr inbounds i32, i32* %82, i64 4
  %86 = bitcast i32* %85 to <4 x i32>*
  %87 = load <4 x i32>, <4 x i32>* %86, align 4, !tbaa !5, !alias.scope !12
  %88 = add <4 x i32> %84, %78
  %89 = add <4 x i32> %87, %81
  %90 = getelementptr inbounds i32, i32* %0, i64 %73
  %91 = bitcast i32* %90 to <4 x i32>*
  store <4 x i32> %88, <4 x i32>* %91, align 4, !tbaa !5, !alias.scope !14, !noalias !16
  %92 = getelementptr inbounds i32, i32* %90, i64 4
  %93 = bitcast i32* %92 to <4 x i32>*
  store <4 x i32> %89, <4 x i32>* %93, align 4, !tbaa !5, !alias.scope !14, !noalias !16
  br label %94

94:                                               ; preds = %72, %75
  %95 = icmp eq i64 %21, %7
  br i1 %95, label %117, label %96

96:                                               ; preds = %9, %6, %94
  %97 = phi i64 [ 0, %9 ], [ 0, %6 ], [ %21, %94 ]
  %98 = xor i64 %97, -1
  %99 = add nsw i64 %98, %7
  %100 = and i64 %7, 3
  %101 = icmp eq i64 %100, 0
  br i1 %101, label %114, label %102

102:                                              ; preds = %96, %102
  %103 = phi i64 [ %111, %102 ], [ %97, %96 ]
  %104 = phi i64 [ %112, %102 ], [ 0, %96 ]
  %105 = getelementptr inbounds i32, i32* %1, i64 %103
  %106 = load i32, i32* %105, align 4, !tbaa !5
  %107 = getelementptr inbounds i32, i32* %2, i64 %103
  %108 = load i32, i32* %107, align 4, !tbaa !5
  %109 = add i32 %108, %106
  %110 = getelementptr inbounds i32, i32* %0, i64 %103
  store i32 %109, i32* %110, align 4, !tbaa !5
  %111 = add nuw nsw i64 %103, 1
  %112 = add i64 %104, 1
  %113 = icmp eq i64 %112, %100
  br i1 %113, label %114, label %102, !llvm.loop !20

114:                                              ; preds = %102, %96
  %115 = phi i64 [ %97, %96 ], [ %111, %102 ]
  %116 = icmp ult i64 %99, 3
  br i1 %116, label %117, label %118

117:                                              ; preds = %114, %118, %94, %4
  ret void

118:                                              ; preds = %114, %118
  %119 = phi i64 [ %147, %118 ], [ %115, %114 ]
  %120 = getelementptr inbounds i32, i32* %1, i64 %119
  %121 = load i32, i32* %120, align 4, !tbaa !5
  %122 = getelementptr inbounds i32, i32* %2, i64 %119
  %123 = load i32, i32* %122, align 4, !tbaa !5
  %124 = add i32 %123, %121
  %125 = getelementptr inbounds i32, i32* %0, i64 %119
  store i32 %124, i32* %125, align 4, !tbaa !5
  %126 = add nuw nsw i64 %119, 1
  %127 = getelementptr inbounds i32, i32* %1, i64 %126
  %128 = load i32, i32* %127, align 4, !tbaa !5
  %129 = getelementptr inbounds i32, i32* %2, i64 %126
  %130 = load i32, i32* %129, align 4, !tbaa !5
  %131 = add i32 %130, %128
  %132 = getelementptr inbounds i32, i32* %0, i64 %126
  store i32 %131, i32* %132, align 4, !tbaa !5
  %133 = add nuw nsw i64 %119, 2
  %134 = getelementptr inbounds i32, i32* %1, i64 %133
  %135 = load i32, i32* %134, align 4, !tbaa !5
  %136 = getelementptr inbounds i32, i32* %2, i64 %133
  %137 = load i32, i32* %136, align 4, !tbaa !5
  %138 = add i32 %137, %135
  %139 = getelementptr inbounds i32, i32* %0, i64 %133
  store i32 %138, i32* %139, align 4, !tbaa !5
  %140 = add nuw nsw i64 %119, 3
  %141 = getelementptr inbounds i32, i32* %1, i64 %140
  %142 = load i32, i32* %141, align 4, !tbaa !5
  %143 = getelementptr inbounds i32, i32* %2, i64 %140
  %144 = load i32, i32* %143, align 4, !tbaa !5
  %145 = add i32 %144, %142
  %146 = getelementptr inbounds i32, i32* %0, i64 %140
  store i32 %145, i32* %146, align 4, !tbaa !5
  %147 = add nuw nsw i64 %119, 4
  %148 = icmp eq i64 %147, %7
  br i1 %148, label %117, label %118, !llvm.loop !22
}

; Function Attrs: nofree nosync nounwind readnone uwtable
define dso_local i32 @bpf_prog(i32* nocapture noundef readnone %0) local_unnamed_addr #1 {
  ret i32 24
}

attributes #0 = { nofree norecurse nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nofree nosync nounwind readnone uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = !{!10}
!10 = distinct !{!10, !11}
!11 = distinct !{!11, !"LVerDomain"}
!12 = !{!13}
!13 = distinct !{!13, !11}
!14 = !{!15}
!15 = distinct !{!15, !11}
!16 = !{!10, !13}
!17 = distinct !{!17, !18, !19}
!18 = !{!"llvm.loop.mustprogress"}
!19 = !{!"llvm.loop.isvectorized", i32 1}
!20 = distinct !{!20, !21}
!21 = !{!"llvm.loop.unroll.disable"}
!22 = distinct !{!22, !18, !19}
