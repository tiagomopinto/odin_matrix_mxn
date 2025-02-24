package main

import mtx "matrix_mxn"

main :: proc() {

	m1 := matrix[3, 3]f64{
		1, 2, 3, 
		4, 5, 6, 
		7, 8, 9, 
	}

	m2 := matrix[3, 3]f64{
		9, 8, 7, 
		6, 5, 4, 
		3, 2, 1, 
	}

	m_9x6 := mtx.make_matrix(9, 6)

	defer mtx.free_matrix(&m_9x6)

	mtx.assign_matrix_from_std_matrices_3x3(m_9x6, {m1, m2}, {m1, m2}, {m1, m2})

	m_inv_6x9 := mtx.pinv(m_9x6)

	defer mtx.free_matrix(&m_inv_6x9)

	mtx.print_matrix(m_9x6)

	mtx.print_matrix(m_inv_6x9)
}
