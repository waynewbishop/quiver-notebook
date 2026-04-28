import Quiver
import Foundation

// --- user code begins ---
import Quiver

// Four test scores from a class
let scores = [85.0, 72.0, 91.0, 68.0]
                                                                                                                                                                
// Pre-computed statistics                                         
let mean: Double = 79.0                                                                                                                                          
let stdDev: Double = 10.0                                                                                                                                        

// Standardize the column using broadcasting                                                                                                                     
let zScores = (scores - mean) / stdDev                             
// [0.6, -0.7, 1.2, -1.1]      

// --- user code ends ---