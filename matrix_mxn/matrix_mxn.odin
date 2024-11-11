package matrix_mxn

import "core:fmt"
import "core:math"
import "core:os"

Matrix :: struct {
	rows_num: int,
	cols_num: int,
	data:     []f64,
}

@(private)
check_error :: #force_inline proc(ptr: rawptr, msg: string) {

	if ptr == nil {

		fmt.println(msg)
		os.exit(1)
	}
}

set_val :: #force_inline proc(mat: ^Matrix, row_idx: int, col_idx: int, val: f64) {

	mat.data[row_idx * mat.cols_num + col_idx] = val
}

get_val :: #force_inline proc(mat: ^Matrix, row_idx: int, col_idx: int) -> (val: f64) {

	return mat.data[row_idx * mat.cols_num + col_idx]
}

get_row :: proc(mat: ^Matrix, row_idx: int, row: []f64) {

	assert(mat.cols_num == len(row))

	for i in 0 ..< mat.cols_num {

		row[i] = get_val(mat, row_idx, i)
	}
}

get_col :: proc(mat: ^Matrix, col_idx: int, col: []f64) {

	assert(mat.rows_num == len(col))

	for i in 0 ..< mat.rows_num {

		col[i] = get_val(mat, i, col_idx)
	}
}

get_diag :: proc(mat: ^Matrix) -> (diag: []f64) {

	assert(mat.rows_num == mat.cols_num)

	diag = make([]f64, mat.rows_num)

	check_error(&diag[0], "ERROR: in Matrix: Memory allocation failed for diag in get_diag().")

	for i in 0 ..< mat.rows_num {

		diag[i] = get_val(mat, i, i)
	}

	return diag
}

make_matrix :: proc(rows_num: int, cols_num: int) -> (mat: ^Matrix) {

	mat = new(Matrix)

	check_error(mat, "ERROR in Matrix: Memory allocation failed for mat in make_matrix().")

	mat.rows_num = rows_num
	mat.cols_num = cols_num

	mat.data = make([]f64, rows_num * cols_num)

	check_error(
		&mat.data[0],
		"ERROR in Matrix: Memory allocation failed for mat.data in make_matrix().",
	)

	return mat
}

make_matrix_from_3x3 :: proc(rows_3x3: ..[]^matrix[3, 3]f64) -> (mat: ^Matrix) {

	rows_num_3x3 := len(rows_3x3)
	cols_num_3x3 := len(rows_3x3[0])

	for row_3x3 in rows_3x3 {

		assert(cols_num_3x3 == len(row_3x3)) // check if all rows have the same length (rectangular or square matrix)
	}

	mat = make_matrix(3 * rows_num_3x3, 3 * cols_num_3x3)

	for rows_3x3_idx in 0 ..< rows_num_3x3 {

		for i in 0 ..< 3 {

			for cols_3x3_idx in 0 ..< cols_num_3x3 {

				for j in 0 ..< 3 {

					set_val(
						mat,
						3 * rows_3x3_idx + i,
						3 * cols_3x3_idx + j,
						rows_3x3[rows_3x3_idx][cols_3x3_idx][i, j],
					)
				}
			}
		}
	}

	return mat
}

copy_matrix :: proc(m1: ^Matrix, m2: ^Matrix) {

	assert(m1.rows_num == m2.rows_num && m1.cols_num == m2.cols_num)

	for i in 0 ..< m1.rows_num {

		for j in 0 ..< m1.cols_num {

			set_val(m2, i, j, get_val(m1, i, j))
		}
	}
}

convert_to_std_matrix_3x3_type :: proc(mat: ^Matrix, mat_std: ^matrix[3, 3]f64) {

	assert(mat.rows_num == 3 && mat.cols_num == 3)

	for i in 0 ..< 3 {

		for j in 0 ..< 3 {

			mat_std[i, j] = get_val(mat, i, j)
		}
	}
}

free_matrix :: proc(mat: ^^Matrix) {

	delete(mat^^.data)

	mat^^.data = nil

	free(mat^)

	mat^ = nil
}

print_matrix :: proc(mat: ^Matrix) {

	for i in 0 ..< mat.rows_num {

		line_start_idx := i * mat.cols_num
		line_end_idx := line_start_idx + mat.cols_num

		fmt.println(mat.data[line_start_idx:line_end_idx])
	}
}

zeros :: proc(size: int) -> (mat: ^Matrix) {

	mat = make_matrix(size, size)

	return mat
}

eye :: proc(size: int) -> (mat: ^Matrix) {

	mat = make_matrix(size, size)

	for i in 0 ..< size {

		set_val(mat, i, i, 1)
	}

	return mat
}

trace :: proc(mat: ^Matrix) -> (res: f64) {

	diag := get_diag(mat)
	defer delete(diag)

	res = 0.0

	for val in diag {

		res += val
	}

	return res
}

sum :: proc(m1: ^Matrix, m2: ^Matrix, m_res: ^Matrix) {

	assert(
		m1.rows_num == m2.rows_num &&
		m1.cols_num == m2.cols_num &&
		m1.rows_num == m_res.rows_num &&
		m1.cols_num == m_res.cols_num,
	)

	for i in 0 ..< m_res.rows_num {

		for j in 0 ..< m_res.cols_num {

			val1 := get_val(m1, i, j)
			val2 := get_val(m2, i, j)

			set_val(m_res, i, j, val1 + val2)
		}
	}
}

subtract :: proc(m1: ^Matrix, m2: ^Matrix, m_res: ^Matrix) {

	assert(
		m1.rows_num == m2.rows_num &&
		m1.cols_num == m2.cols_num &&
		m1.rows_num == m_res.rows_num &&
		m1.cols_num == m_res.cols_num,
	)

	for i in 0 ..< m_res.rows_num {

		for j in 0 ..< m_res.cols_num {

			val1 := get_val(m1, i, j)
			val2 := get_val(m2, i, j)

			set_val(m_res, i, j, val1 - val2)
		}
	}
}

mult :: proc(m1: ^Matrix, m2: ^Matrix, m_res: ^Matrix) {

	assert(
		m1.cols_num == m2.rows_num &&
		m1.rows_num == m_res.rows_num &&
		m2.cols_num == m_res.cols_num,
	)

	for i in 0 ..< m1.rows_num {

		for j in 0 ..< m2.cols_num {

			set_val(m_res, i, j, 0.0)

			for k in 0 ..< m1.cols_num {

				val_new := get_val(m1, i, k) * get_val(m2, k, j)

				val_old := get_val(m_res, i, j)

				set_val(m_res, i, j, val_old + val_new)
			}
		}
	}
}

transpose :: proc(mat: ^Matrix, mat_t: ^Matrix) {

	assert(mat.rows_num == mat_t.cols_num && mat.cols_num == mat_t.rows_num)

	for i in 0 ..< mat.rows_num {

		for j in 0 ..< mat.cols_num {

			set_val(mat_t, j, i, get_val(mat, i, j))
		}
	}
}

pinv :: proc(mat_a_mxn: ^Matrix) -> (mat_inv_nxm: ^Matrix) {

	m := mat_a_mxn.rows_num
	n := mat_a_mxn.cols_num

	mat_inv_nxm = make_matrix(n, m)

	mat_aux_nxm := make_matrix(n, m)
	defer free_matrix(&mat_aux_nxm)

	mat_aux1_nxn := zeros(n)
	defer free_matrix(&mat_aux1_nxn)

	mat_aux2_nxn := zeros(n)
	defer free_matrix(&mat_aux2_nxn)

	mat_aux3_nxn := zeros(n)
	defer free_matrix(&mat_aux3_nxn)

	mat_q_nxn := zeros(n)
	defer free_matrix(&mat_q_nxn)

	mat_v_nxn := eye(n)
	defer free_matrix(&mat_v_nxn)

	w := make([]f64, n)
	defer delete(w)

	q := make([]f64, n)
	defer delete(q)

	transpose(mat_a_mxn, mat_aux_nxm)

	mult(mat_aux_nxm, mat_a_mxn, mat_aux1_nxn)

	for k in 0 ..< 10 {

		for j in 0 ..< n {

			get_col(mat_aux1_nxn, j, w)

			for i in 0 ..< j {

				get_col(mat_q_nxn, i, q)

				dot_prod := 0.0

				for idx in 0 ..< n {

					dot_prod += q[idx] * w[idx]
				}

				for idx in 0 ..< n {

					w[idx] -= dot_prod * q[idx]
				}
			}

			w_norm := 0.0

			for idx in 0 ..< n {

				w_norm += w[idx] * w[idx]
			}

			w_norm = math.sqrt(w_norm)

			for i in 0 ..< n {

				set_val(mat_q_nxn, i, j, w[i] / w_norm)
			}
		}

		transpose(mat_q_nxn, mat_aux2_nxn) // Q_t

		mult(mat_aux1_nxn, mat_q_nxn, mat_aux3_nxn) // A_aux x Q

		mult(mat_aux2_nxn, mat_aux3_nxn, mat_aux1_nxn) // Q_t x (A_aux x Q) = A_aux

		mult(mat_v_nxn, mat_q_nxn, mat_aux2_nxn) // V x Q

		copy_matrix(mat_aux2_nxn, mat_v_nxn) // (V x Q) = V
	}

	max: int

	if m > n {

		max = n

	} else {

		max = m
	}

	mat_aux_mxn := make_matrix(m, n) // E matrix
	defer free_matrix(&mat_aux_mxn)

	for i in 0 ..< max {

		eig_val := get_val(mat_aux1_nxn, i, i)

		if math.abs(eig_val) > 2.220446049250313e-16 { 	// if > f64 resolution

			set_val(mat_aux_mxn, i, i, 1.0 / math.sqrt(eig_val))
		}
	}

	mat_et_nxm := make_matrix(n, m)
	defer free_matrix(&mat_et_nxm)

	mat_u_mxm := make_matrix(m, m)
	defer free_matrix(&mat_u_mxm)

	mat_ut_mxm := make_matrix(m, m)
	defer free_matrix(&mat_ut_mxm)

	transpose(mat_aux_mxn, mat_et_nxm) // E_t

	mult(mat_a_mxn, mat_v_nxn, mat_aux_mxn) // A x V

	mult(mat_aux_mxn, mat_et_nxm, mat_u_mxm) // (A x V) x E_t = U

	transpose(mat_u_mxm, mat_ut_mxm) // U_t

	mult(mat_v_nxn, mat_et_nxm, mat_aux_nxm) // V x E_t

	mult(mat_aux_nxm, mat_ut_mxm, mat_inv_nxm) // (V x E_t) x U_t = A_inv

	return mat_inv_nxm
}
