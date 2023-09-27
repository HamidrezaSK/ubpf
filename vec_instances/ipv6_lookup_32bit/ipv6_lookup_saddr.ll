; ModuleID = 'ipv6_lookup_saddr.c'
source_filename = "ipv6_lookup_saddr.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.IPv6Rule = type { %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, %struct.in6_addr, i16, i16, i16, i16, i8, i8 }
%struct.in6_addr = type { %union.anon }
%union.anon = type { [4 x i32] }

@lookups = dso_local local_unnamed_addr global [4 x %struct.IPv6Rule] [%struct.IPv6Rule { %struct.in6_addr { %union.anon { [4 x i32] [i32 704850048, i32 -233176957, i32 -87117813, i32 57701172] } }, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, i16 0, i16 0, i16 0, i16 0, i8 0, i8 0 }, %struct.IPv6Rule { %struct.in6_addr { %union.anon { [4 x i32] [i32 704850048, i32 -233176957, i32 -87117813, i32 326111796] } }, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, i16 0, i16 0, i16 0, i16 0, i8 0, i8 0 }, %struct.IPv6Rule { %struct.in6_addr { %union.anon { [4 x i32] [i32 704850048, i32 -233176957, i32 -87117813, i32 633870662] } }, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, i16 0, i16 0, i16 0, i16 0, i8 0, i8 0 }, %struct.IPv6Rule { %struct.in6_addr { %union.anon { [4 x i32] [i32 704850048, i32 -233176957, i32 -87117813, i32 56632798] } }, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, %struct.in6_addr zeroinitializer, i16 0, i16 0, i16 0, i16 0, i8 0, i8 0 }], align 16

; Function Attrs: mustprogress nofree nosync nounwind uwtable willreturn
define dso_local i64 @is_dst_one_one_one_one(i8* nocapture noundef readonly %0) local_unnamed_addr #0 {
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
  %14 = tail call i32 @llvm.bswap.i32(i32 %4) #2
  %15 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 0), align 16, !tbaa !6
  %16 = icmp eq i32 %14, %15
  br i1 %16, label %17, label %29

17:                                               ; preds = %1
  %18 = tail call i32 @llvm.bswap.i32(i32 %7) #2
  %19 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 1), align 4, !tbaa !6
  %20 = icmp eq i32 %18, %19
  br i1 %20, label %21, label %29

21:                                               ; preds = %17
  %22 = tail call i32 @llvm.bswap.i32(i32 %10) #2
  %23 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 2), align 8, !tbaa !6
  %24 = icmp eq i32 %22, %23
  br i1 %24, label %25, label %29

25:                                               ; preds = %21
  %26 = tail call i32 @llvm.bswap.i32(i32 %13) #2
  %27 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 0, i32 0, i32 0, i32 0, i64 3), align 4, !tbaa !6
  %28 = icmp eq i32 %26, %27
  br i1 %28, label %30, label %29

29:                                               ; preds = %25, %21, %17, %1
  br label %30

30:                                               ; preds = %25, %29
  %31 = phi i64 [ 0, %29 ], [ 1, %25 ]
  %32 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 1, i32 0, i32 0, i32 0, i64 0), align 4, !tbaa.struct !12
  %33 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 1, i32 0, i32 0, i32 0, i64 1), align 16, !tbaa.struct !17
  %34 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 1, i32 0, i32 0, i32 0, i64 2), align 4, !tbaa.struct !18
  %35 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 1, i32 0, i32 0, i32 0, i64 3), align 8, !tbaa.struct !19
  %36 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 0), align 8, !tbaa !6
  %37 = icmp eq i32 %14, %36
  %38 = tail call i32 @llvm.bswap.i32(i32 %7) #2
  %39 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 1), align 4
  %40 = icmp eq i32 %38, %39
  %41 = select i1 %37, i1 %40, i1 false
  br i1 %41, label %42, label %50

42:                                               ; preds = %30
  %43 = tail call i32 @llvm.bswap.i32(i32 %10) #2
  %44 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 2), align 16, !tbaa !6
  %45 = icmp eq i32 %43, %44
  br i1 %45, label %46, label %50

46:                                               ; preds = %42
  %47 = tail call i32 @llvm.bswap.i32(i32 %13) #2
  %48 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 2, i32 0, i32 0, i32 0, i64 3), align 4, !tbaa !6
  %49 = icmp eq i32 %47, %48
  br i1 %49, label %53, label %50

50:                                               ; preds = %30, %46, %42
  %51 = tail call i32 @llvm.bswap.i32(i32 %10) #2
  %52 = tail call i32 @llvm.bswap.i32(i32 %13) #2
  br label %53

53:                                               ; preds = %46, %50
  %54 = phi i32 [ %47, %46 ], [ %52, %50 ]
  %55 = phi i32 [ %43, %46 ], [ %51, %50 ]
  %56 = phi i64 [ 1, %46 ], [ 0, %50 ]
  %57 = icmp eq i32 %14, %32
  %58 = icmp eq i32 %38, %33
  %59 = select i1 %57, i1 %58, i1 false
  %60 = icmp eq i32 %55, %34
  %61 = select i1 %59, i1 %60, i1 false
  %62 = icmp eq i32 %54, %35
  %63 = select i1 %61, i1 %62, i1 false
  %64 = zext i1 %63 to i64
  %65 = add nuw nsw i64 %31, %64
  %66 = add nuw nsw i64 %65, %56
  %67 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 3, i32 0, i32 0, i32 0, i64 0), align 4, !tbaa.struct !12
  %68 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 3, i32 0, i32 0, i32 0, i64 1), align 8, !tbaa.struct !17
  %69 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 3, i32 0, i32 0, i32 0, i64 2), align 4, !tbaa.struct !18
  %70 = load i32, i32* getelementptr inbounds ([4 x %struct.IPv6Rule], [4 x %struct.IPv6Rule]* @lookups, i64 0, i64 3, i32 0, i32 0, i32 0, i64 3), align 16, !tbaa.struct !19
  %71 = icmp eq i32 %14, %67
  %72 = icmp eq i32 %38, %68
  %73 = select i1 %71, i1 %72, i1 false
  %74 = icmp eq i32 %55, %69
  %75 = select i1 %73, i1 %74, i1 false
  %76 = icmp eq i32 %54, %70
  %77 = select i1 %75, i1 %76, i1 false
  %78 = zext i1 %77 to i64
  %79 = add nuw nsw i64 %66, %78
  ret i64 %79
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i32 @llvm.bswap.i32(i32) #1

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
!12 = !{i64 0, i64 16, !6, i64 0, i64 16, !6, i64 0, i64 16, !6, i64 16, i64 16, !6, i64 16, i64 16, !6, i64 16, i64 16, !6, i64 32, i64 16, !6, i64 32, i64 16, !6, i64 32, i64 16, !6, i64 48, i64 16, !6, i64 48, i64 16, !6, i64 48, i64 16, !6, i64 64, i64 2, !13, i64 66, i64 2, !13, i64 68, i64 2, !13, i64 70, i64 2, !13, i64 72, i64 1, !6, i64 73, i64 1, !15}
!13 = !{!14, !14, i64 0}
!14 = !{!"short", !7, i64 0}
!15 = !{!16, !16, i64 0}
!16 = !{!"_Bool", !7, i64 0}
!17 = !{i64 0, i64 12, !6, i64 0, i64 12, !6, i64 0, i64 12, !6, i64 12, i64 16, !6, i64 12, i64 16, !6, i64 12, i64 16, !6, i64 28, i64 16, !6, i64 28, i64 16, !6, i64 28, i64 16, !6, i64 44, i64 16, !6, i64 44, i64 16, !6, i64 44, i64 16, !6, i64 60, i64 2, !13, i64 62, i64 2, !13, i64 64, i64 2, !13, i64 66, i64 2, !13, i64 68, i64 1, !6, i64 69, i64 1, !15}
!18 = !{i64 0, i64 8, !6, i64 0, i64 8, !6, i64 0, i64 8, !6, i64 8, i64 16, !6, i64 8, i64 16, !6, i64 8, i64 16, !6, i64 24, i64 16, !6, i64 24, i64 16, !6, i64 24, i64 16, !6, i64 40, i64 16, !6, i64 40, i64 16, !6, i64 40, i64 16, !6, i64 56, i64 2, !13, i64 58, i64 2, !13, i64 60, i64 2, !13, i64 62, i64 2, !13, i64 64, i64 1, !6, i64 65, i64 1, !15}
!19 = !{i64 0, i64 4, !6, i64 0, i64 4, !6, i64 0, i64 4, !6, i64 4, i64 16, !6, i64 4, i64 16, !6, i64 4, i64 16, !6, i64 20, i64 16, !6, i64 20, i64 16, !6, i64 20, i64 16, !6, i64 36, i64 16, !6, i64 36, i64 16, !6, i64 36, i64 16, !6, i64 52, i64 2, !13, i64 54, i64 2, !13, i64 56, i64 2, !13, i64 58, i64 2, !13, i64 60, i64 1, !6, i64 61, i64 1, !15}
