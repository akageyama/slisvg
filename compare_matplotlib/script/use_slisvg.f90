program main
    use slisvg_m
    use slisvg_color_m
    use slisvg_sketch_m
    use slisvg_slice_scalar_m
    use slisvg_slice_vector_m

    implicit none
    integer :: num_grid, num_slice, num_time, num_level
    integer :: i_line, i_x, i_y, i_z, i_t, i_v
    integer :: unit_data
    real :: x, y, z, u, v, w
    real :: l_min, l_max, v_min, v_max, dv, level
    real :: time_load, time_plot
    integer :: start, end, rate
    real, allocatable :: grid_x(:)
    real, allocatable :: grid_y(:)
    real, allocatable :: field3d_u(:,:,:)
    real, allocatable :: field3d_v(:,:,:)
    real, allocatable :: field3d_w(:,:,:)
    character(len=256) :: filename, svgname
    
    type(slisvg_sketch_t) :: slisvg_sketch
    type(slisvg_slice_scalar_t) :: slisvg_scalar
    type(slisvg_slice_vector_t) :: slisvg_vector
    type(slisvg_color_t) :: color

    open(newunit=unit_data, file='./data/param.txt')
    read(unit_data, *) num_grid, num_slice, num_time
    close(unit_data)

    allocate(grid_x(num_grid))
    allocate(grid_y(num_grid))
    allocate(field3d_u(num_grid,num_grid,num_slice))
    allocate(field3d_v(num_grid,num_grid,num_slice))
    allocate(field3d_w(num_grid,num_grid,num_slice))

    num_level = 10

    time_load = 0.0
    time_plot = 0.0

    do i_t = 0, num_time - 1

        call system_clock(start, rate) 
        write(filename,'(A,I4.4,A)') './data/data_', i_t, '.txt'
        open(newunit=unit_data, file=filename)

        ! ===== Read data =====
        do i_line = 1, num_grid**2 * num_slice
            read(unit_data, *) i_x, i_y, i_z, x, y, z, u, v, w
            grid_x(i_x+1) = x
            grid_y(i_y+1) = y
            field3d_u(i_x+1,i_y+1,i_z+1) = u
            field3d_v(i_x+1,i_y+1,i_z+1) = v
            field3d_w(i_x+1,i_y+1,i_z+1) = w
        end do
        call system_clock(end)
        time_load = time_load + real(end - start) / real(rate)

        close(unit_data)

        if (i_t == 0) then
            l_min = minval(grid_x)
            l_max = maxval(grid_x)
            v_min = minval(field3d_w)
            v_max = maxval(field3d_w)
            dv = (v_max - v_min) / (num_level - 1)
        end if

        call system_clock(start, rate)
        do i_z = 1, num_slice

            write(svgname,'(A,I4.4,A,I4.4,A)')  &
                './output/slisvg/slice_', i_z, '_s=', i_t, '.svg'

            ! ===== Initialize =====
            call slisvg_scalar%initialize( 'vertical flow',  &
                                           num_grid, num_grid,  &
                                           grid_x, grid_y,  &
                                           field3d_w(:,:,i_z))
            call slisvg_vector%initialize( 'horizontal flow',  &
                                           num_grid, num_grid,  &
                                           grid_x, grid_y,  &
                                           field3d_u(:,:,i_z),  &
                                           field3d_v(:,:,i_z) )
            call slisvg_sketch%initialize( l_min, l_min,  &
                                           l_max, l_max,  &
                                           screen_width_in_pixel=800.0, &
                                           title='ABC flow',  &
                                           filename=svgname,  &
                                           unit_arrow_in_pixel=20.0,  &
                                           write_arrow_template= .true. )

            call slisvg_scalar%mesh%draw( slisvg_sketch,  &
                                          line_color=SLISVG_COLOR__CONST%black,  &
                                          width_in_pixels=2.0 )

            call slisvg_sketch%group_push( line_color=SLISVG_COLOR__CONST%black,  &
            fill_color=SLISVG_COLOR__CONST%blue )

            ! ===== Visualize contour =====
            do i_v = 1, num_level
                level = v_min + dv * real(i_v-1)
                color = slisvg_color__real_to_color( vmin=v_min,  &
                                                     vmax=v_max,  &
                                                     val=level )
                
                if ( level >= 0 ) then
                    call slisvg_scalar%vis_contour( slisvg_sketch,  &
                                                    level,  &
                                                    fill_color=color )
                else
                    call slisvg_scalar%vis_contour( slisvg_sketch,  &
                                                    level,  &
                                                    fill_color=color,  &
                                                    line_dash_array="10, 5" )
                end if
            end do

            ! ===== Visualize arrows =====
            call slisvg_vector%vis_arrows( slisvg_sketch,  &
                                           arrow_template="#arrow02" )

            call slisvg_sketch%group_pop

            ! ===== Finalize =====
            call slisvg_scalar%finalize
            call slisvg_vector%finalize
            call slisvg_sketch%finalize

        end do
        call system_clock(end)
        time_plot = time_plot + real(end - start) / real(rate)

    end do

    print *, "Load time: ", time_load, " sec"
    print *, "Plot time: ", time_plot, " sec"

end program main