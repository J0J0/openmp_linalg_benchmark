
module Operations
    integer, parameter :: rk = selected_real_kind(14)
    
contains
    
    function vec_add_do(a, b) result(c)
        real(rk), intent(in)    ::  a(:), b(:)
        real(rk), allocatable   ::  c(:)
        integer                 ::  i, N
        
        N = size(a,1)
        allocate( c(N) )
        
        !$omp parallel do shared(a,b,c) schedule(runtime) if(N > 23000)
        do i = 1, N
            c(i) = a(i) + b(i)
        end do
        !$omp end parallel do
    end function
    
    function vec_add_forall(a, b) result(c)
        real(rk), intent(in)    ::  a(:), b(:)
        real(rk), allocatable   ::  c(:)
        integer                 ::  i, N
        
        N = size(a,1)
        allocate( c(N) )
        
        !$omp parallel workshare shared(a,b,c)
        forall( i=1:N )
            c(i) = a(i) + b(i)
        end forall
        !$omp end parallel workshare
    end function
    
    subroutine daypx_do(a, y, x)
        real(rk), intent(inout) ::  y(:)
        real(rk), intent(in)    ::  a, x(:)
        integer                 ::  i, N
        
        N = size(y, 1)
        
        !$omp parallel do shared(a,y,x) schedule(runtime) if(N > 2400)
        do i = 1, N
            y(i) = a*y(i) + x(i)
        end do
        !$omp end parallel do
    end subroutine
    
    subroutine daypx_forall(a, y, x)
        real(rk), intent(inout) ::  y(:)
        real(rk), intent(in)    ::  a, x(:)
        integer                 ::  i, N
        
        N = size(y, 1)
        
        !$omp parallel workshare shared(a,y,x)
        forall( i=1:N )
            y(i) = a*y(i) + x(i)
        end forall
        !$omp end parallel workshare
    end subroutine
    
    subroutine matrix_mult_do(A, B, C)
        real(rk), intent(in)                ::  A(:,:), B(:,:)
        real(rk), intent(out), allocatable  ::  C(:,:)
        integer                             ::  i, j, k, N
        
        N = size(A,1)
        allocate( C(N,N) )
        C = 0.0

        !$omp parallel do shared(A,B,C) schedule(runtime) if(N > 180)
        do j = 1, N
            do i = 1, N
                do k = 1, N
                    C(i,j) = C(i,j) + A(i,k)*B(k,j)
                end do
            end do
        end do
        !$omp end parallel do
    end subroutine
    
    subroutine matrix_mult_forall(A, B, C)
        real(rk), intent(in)                ::  A(:,:), B(:,:)
        real(rk), intent(out), allocatable  ::  C(:,:)
        integer                             ::  i, j, k, N
        
        N = size(A,1)
        allocate( C(N,N) )
        C = 0.0
        
        !$omp parallel workshare shared(A,B,C)
        forall( j=1:N, i=1:N )
            forall( k=1:N )
                C(i,j) = C(i,j) + A(i,k)*B(k,j)
            end forall
        end forall
        !$omp end parallel workshare
    end subroutine

end module
