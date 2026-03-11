.section __TEXT,__text,regular,pure_instructions
.globl _compute_series_arm
.globl _compute_y_arm
.p2align 2

// Функция для вычисления суммы ряда S(x)
// Вход: d0 = x, d1 = eps
// Выход: d0 = результат S(x)
// Примечание: число итераций сохраняется в глобальной переменной или можно модифицировать для возврата пары значений
_compute_series_arm:
    stp     x29, x30, [sp, #-80]!
    mov     x29, sp
    
    // Сохраняем регистры
    stp     d8, d9, [sp, #16]
    stp     d10, d11, [sp, #32]
    stp     d12, d13, [sp, #48]
    stp     x19, x20, [sp, #64]   // сохраняем callee-saved registers
    
    fmov    d8, d0          // сохраняем x
    fmov    d9, d1          // сохраняем eps
    
    fmov    d10, #1.0       // sum = 1.0 (k=0)
    fmov    d11, #1.0       // factorial = 1.0 (0!)
    
    mov     x19, #1         // k = 1 (целочисленный счетчик)
    mov     x20, #1         // iteration count (начинаем с 1, т.к. k=0 уже учтен)

L_loop_series:
    // Вычисляем kx
    scvtf   d12, x19        // конвертируем k в float
    fmul    d0, d8, d12     // x * k
    
    // Сохраняем регистры перед вызовом cos
    stp     x19, x20, [sp, #-16]!
    stp     d8, d9, [sp, #-16]!
    stp     d10, d11, [sp, #-16]!
    stp     d12, d13, [sp, #-16]!
    
    bl      _cos            // cos(kx) результат в d0
    
    // Восстанавливаем регистры
    ldp     d12, d13, [sp], #16
    ldp     d10, d11, [sp], #16
    ldp     d8, d9, [sp], #16
    ldp     x19, x20, [sp], #16
    
    // Обновляем факториал: factorial *= k
    scvtf   d13, x19        // текущее k как float
    fmul    d11, d11, d13   // factorial = factorial * k
    
    // term = cos(kx) / factorial
    fdiv    d14, d0, d11    // term
    
    // sum += term
    fadd    d10, d10, d14   // sum += term
    
    // Увеличиваем счетчик итераций
    add     x20, x20, #1    // iteration count++
    
    // Проверяем |term| < eps
    fabs    d15, d14
    fcmp    d15, d9
    b.lt    L_done_series
    
    // Увеличиваем k
    add     x19, x19, #1    // k++
    
    // Предохранитель: не более 200 итераций
    cmp     x19, #200
    b.le    L_loop_series

L_done_series:
    fmov    d0, d10         // возвращаем сумму
    
    // Здесь можно сохранить число итераций в глобальную переменную
    // или модифицировать функцию для возврата пары значений
    
    // Восстанавливаем регистры
    ldp     x19, x20, [sp, #64]
    ldp     d12, d13, [sp, #48]
    ldp     d10, d11, [sp, #32]
    ldp     d8, d9, [sp, #16]
    ldp     x29, x30, [sp], #80
    ret

// Функция для вычисления Y(x) = e^(cos(x)) * cos(sin(x))
_compute_y_arm:
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    
    stp     d8, d9, [sp, #16]
    stp     d10, d11, [sp, #32]
    
    fmov    d8, d0          // сохраняем x
    
    // Вычисляем cos(x)
    stp     d8, d9, [sp, #-16]!
    bl      _cos
    ldp     d8, d9, [sp], #16
    fmov    d9, d0          // cos(x)
    
    // Вычисляем e^(cos(x))
    fmov    d0, d9
    stp     d8, d9, [sp, #-16]!
    bl      _exp
    ldp     d8, d9, [sp], #16
    fmov    d10, d0         // e^(cos(x))
    
    // Вычисляем sin(x)
    fmov    d0, d8
    stp     d8, d9, [sp, #-16]!
    stp     d10, d11, [sp, #-16]!
    bl      _sin
    ldp     d10, d11, [sp], #16
    ldp     d8, d9, [sp], #16
    fmov    d11, d0         // sin(x)
    
    // Вычисляем cos(sin(x))
    fmov    d0, d11
    stp     d8, d9, [sp, #-16]!
    stp     d10, d11, [sp, #-16]!
    bl      _cos
    ldp     d10, d11, [sp], #16
    ldp     d8, d9, [sp], #16
    fmov    d11, d0         // cos(sin(x))
    
    // Перемножаем
    fmul    d0, d10, d11
    
    ldp     d10, d11, [sp, #32]
    ldp     d8, d9, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret