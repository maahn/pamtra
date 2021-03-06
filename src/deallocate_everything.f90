module deallocate_everything
  implicit none
  contains
    subroutine do_deallocate_everything(errorstatus)

        !
        ! Description:
        !   This routine cleans up and deallocates all variables which could be allocated
        !
        ! Current Code Owner: IGMK
        !
        ! History:
        !
        ! Version   Date       Comment
        ! -------   ----       -------
        ! 0.1       13/07/2009 Created by M.Maahn
        ! Code Description:
        !   Language:               Fortran 90.
        !   Software Standards: "European Standards for Writing and  
        !     Documenting Exchangeable Fortran 90 Code". 
        !


        use kinds
        use report_module

        use descriptor_file, only: deallocate_descriptor_file
        use drop_size_dist, only: deallocateVars_drop_size_dist
        use scatProperties, only: deallocate_scatProperties
        use vars_output, only: deallocate_output_vars
        use vars_rt, only: deallocate_rt_vars
        use vars_atmosphere, only: deallocate_atmosphere_vars
        use vars_hydroFullSpec, only: deallocate_hydrofs_vars

        integer(kind=long), intent(out) :: errorstatus
        integer(kind=long) :: err = 0
        character(len=30) :: nameOfRoutine = 'deallocate_everything'

        if (verbose >= 2) call report(info,'Start of ', nameOfRoutine)

        call deallocate_descriptor_file()
        call deallocate_output_vars()
        call deallocateVars_drop_size_dist()
        call deallocate_scatProperties()
        call deallocate_rt_vars()
        call deallocate_atmosphere_vars()
        call deallocate_hydrofs_vars()

        if (verbose >= 2) call report(info,'End of ', nameOfRoutine)

        errorstatus = err
        return

    end subroutine do_deallocate_everything
end module deallocate_everything