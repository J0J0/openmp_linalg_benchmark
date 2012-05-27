
module wrapper
    type :: mytype
        real :: anything
    contains
        procedure, pass :: dosth => test_it
    end type
    
contains

    function test_it(a, b)
        type(mytype)        ::  a
        integer, optional   ::  b
        integer             ::  test_it
        
        if( present(b) ) then
            print *, "got b"
        else
            print *, "only a"
        end if
        
        test_it = 42
    end function
end module

program test_present
    use wrapper
    type(mytype) :: T
    integer      :: tmp
    tmp = T%dosth(123)
    print *, "should have got b"
    print *
    tmp = T%dosth()
    print *, "should have only a"
end program
