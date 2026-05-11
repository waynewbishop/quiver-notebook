import Quiver
import Foundation

// --- user code begins ---
// Title: Fahrenheit to Celsius with Broadcasting
//
// Broadcasting applies a scalar to every element of a vector. The textbook
// formula for Fahrenheit-to-Celsius conversion is (F - 32) * 5/9, and with
// Quiver the code reads exactly that way — one line, no loop, no closure.

let temperatures = [72.0, 68.0, 73.0, 70.0, 75.0]

let celsius = (temperatures - 32.0) * 5.0/9.0

print("Fahrenheit (°F):", temperatures.round())
print("Celsius (°C):   ", celsius.round())

// --- user code ends ---