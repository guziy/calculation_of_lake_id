program test

use netcdf
implicit none


! This is the name of the data file we will read.
character (len = *), parameter :: FILE_NAME_IN = &
"/RESCUE/skynet3_rech1/huziy/Netbeans Projects/Java/DDM/directions_great_lakes_210_130_0.1deg_v2.nc"

! Output file
character (len = *), parameter :: FILE_NAME_OUT = "lake_ids.nc"

real, parameter :: global_lakefr_limit = 0.6

! This will be the netCDF ID for the file and data variable.
integer :: ncid, varid, dimid
integer :: nlon, nlat

integer :: i, j, k


 real, allocatable :: lkids(:, :), lkfr(:, :), fldir(:, :), lkout(:, :)
 integer, allocatable :: i_arr(:), j_arr(:)
 integer :: n_upstream, current_id
 character (len=1024) :: dummy_str
 real, allocatable :: tmp_field(:, :)

! Open the file. NF90_NOWRITE tells netCDF we want read-only access to
! the file.
 call check(nf90_open(FILE_NAME_IN, NF90_NOWRITE, ncid) )


! Get dimensions
 call check(nf90_inq_dimid(ncid, "longitude", dimid))
 call check(nf90_inquire_dimension(ncid, dimid, dummy_str, nlon))

 call check(nf90_inq_dimid(ncid, "latitude", dimid))
 call check(nf90_inquire_dimension(ncid, dimid, dummy_str, nlat))

 print *, "nlon = ", nlon
 print *, "nlat = ", nlat

 allocate(tmp_field(nlat, nlon))

 allocate(lkids(nlon, nlat), lkfr(nlon, nlat), fldir(nlon, nlat), lkout(nlon, nlat))
 allocate(i_arr(nlon * nlat), j_arr(nlon * nlat))



 ! Get the varid of the data variable, based on its name.
 call check(nf90_inq_varid(ncid, "flow_direction_value", varid))
 ! Read the data.
 call check(nf90_get_var(ncid, varid, tmp_field))
 fldir = transpose(tmp_field)


 ! Get the varid of the data variable, based on its name.
 call check(nf90_inq_varid(ncid, "lake_fraction", varid))
 ! Read the data.
 call check(nf90_get_var(ncid, varid, tmp_field))
 lkfr = transpose(tmp_field)


 ! Get the varid of the data variable, based on its name.
 call check(nf90_inq_varid(ncid, "lake_outlet", varid))
 ! Read the data.
 call check(nf90_get_var(ncid, varid, tmp_field))
 lkout = transpose(tmp_field)


lkids = 0
current_id = 1
do i = 1, nlon
  do j = 1, nlat

    if (lkout(i, j) < 0.5) then
      cycle
    endif

    i_arr = -1
    j_arr = -1
    n_upstream = 0

    call wtrt_get_previous_lake_indexes_rec(n_upstream,           &
      i_arr, j_arr, fldir, lkfr, i, j,                            &
      1, nlon, 1, nlat, nlon, nlat, global_lakefr_limit)

    do k = 1, n_upstream
      lkids(i_arr(k), j_arr(k)) = current_id
    enddo

    current_id = current_id + 1

  enddo
enddo



! Close the file, freeing all resources.
call check( nf90_close(ncid) )



! Write the result to another netCDF file
! TODO:





contains
  subroutine check(status)
    integer, intent ( in) :: status

    if(status /= nf90_noerr) then
      print *, trim(nf90_strerror(status))
      stop "Stopped"
    end if
  end subroutine check



end program test
