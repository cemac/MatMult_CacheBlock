program cacheBlocking
implicit none

!========= DECLARATIONS ========================
integer, parameter :: sp = selected_real_kind(6, 37)
integer, parameter :: dp = selected_real_kind(15, 307)
integer, parameter :: qp = selected_real_kind(33, 4931)

! CDe: nrow sets the initial dimenions of the matrices, i.e. nrow x nrow  
integer :: nrow=10240                  ! array extents (square mtces)

integer, parameter :: NSZ=10240        ! generic array extents (square mtces)
integer, parameter :: IREP=1           ! loop iterations to perform the matrix multiplication
integer, parameter :: IREDO=1          ! no. of repetitions of main loop

integer :: i,j,k,kk

! CDe declare a,b, and c as allocatable arrays instead to avoid relocation errors during compilation
real(kind=dp),allocatable,dimension(:,:) :: a,b,c

! CDe declare chunk / tile dimensions na,nb (square matrices)
integer :: nb,na

! CDe set value of initial chunk/tile dimensions
integer, parameter :: chunk_dim = 128

!========= BEGIN coding =====================

allocate(a(NSZ,NSZ))
allocate(b(NSZ,NSZ))
allocate(c(NSZ,NSZ))

! initialise
a = 1.0
b = 1.0
c = 0.0

! CDe start outer loop to get timing info
  DO k=1,IREDO 

    na=0
    nb=0

!    DO i=1,IREP ! CDe repeat mat-mult calculation IREP times (to provide more robust timing information)
!       call MMNB(nrow,nrow,nrow,a,b,c)
!    END DO

!   set initial value of chunk/tile size
   nb=chunk_dim  
   na=nb  ! square tile size
   DO i=1,IREP ! repeat calculation IREP times
      call MMBD(nrow,nrow,nrow,a,b,c,na,nb)
   END DO

  END DO  ! K loop 

contains

SUBROUTINE MMNB (n1,n2,n3,a,b,c)
implicit none
! non-blocked matrix multiplication
integer :: n1,n2,n3
real(kind=dp),dimension(NSZ,NSZ), intent(in) :: a,b
real(kind=dp),dimension(NSZ,NSZ), intent(inout) :: c

! locals
integer ii,jj,kk
real(kind=dp) :: sum

! Assume B transposed
do ii = 1,n1
  do jj = 1,n3
     sum = 0.0
     do kk = 1,n2
       sum = sum + a(kk,ii)*b(kk,jj)
     END DO
     c(jj,ii) = sum
  end do ! jj
end do ! ii
end subroutine mmnb


subroutine mmbd (n1,n2,n3,a,b,c, na, nb)
implicit none
! cache-blocked matrix multiplication
integer :: n1,n2,n3, na,nb
real(kind=dp),dimension(NSZ,NSZ), intent(in) :: a,b
real(kind=dp),dimension(NSZ,NSZ), intent(inout) :: c

! locals
integer ii,jj,kk, i_l,j_l
real(kind=dp) :: sum

! this code assumes that the B array has been transposed
do ii = 1,n1,na      ! stride through data
  do jj = 1,n3,nb    ! stride through data
    do i_l = ii,MIN(ii+(na-1),n1)  ! within the chosen block
      do j_l=jj, MIN(jj+(nb-1),n3) ! within the chosen block
        sum = 0.0
        do kk = 1,n2
          sum = sum + a(kk,i_l)*b(kk,j_l)
        END DO ! kk
        c(j_l,i_l) = sum
      end do ! j_l
    end do ! i_l
  end do ! jj
end do ! ii

end subroutine mmbd

end program cacheBlocking
