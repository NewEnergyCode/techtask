package com.userservice.techtask.exception;

import java.time.LocalDateTime;
import java.util.Objects;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@ControllerAdvice()
public class HandlerException {

  /**
   * Handles ResourceNotFoundException and returns a ResponseEntity with a BAD_REQUEST status,
   * including an ApiError object containing the error details.
   */
  @ResponseStatus(HttpStatus.BAD_REQUEST)
  @ExceptionHandler(ResourceNotFoundException.class)
  public ResponseEntity<Object> handleNoFoundExceptions(ResourceNotFoundException ex) {
    ApiError apiError = new ApiError(
        LocalDateTime.now(),
        HttpStatus.BAD_REQUEST.value(),
        ex.getMessage(),
        "Please check your request."
    );
    return new ResponseEntity<>(apiError, new HttpHeaders(), apiError.getStatus());

  }

  /**
   * Handles NoHandlerFoundException and returns a ResponseEntity with a NOT_FOUND status, including
   * an ApiError object containing the error details.
   */
  @ResponseStatus(HttpStatus.NOT_FOUND)
  @ExceptionHandler(NoResourceFoundException.class)
  public ResponseEntity<Object> handleNoResourceFoundException(NoResourceFoundException ex) {
    ApiError apiError = new ApiError(
        LocalDateTime.now(),
        HttpStatus.NOT_FOUND.value(),
        ex.getMessage(),
        "Please check your request`s resource."
    );
    return new ResponseEntity<>(apiError, new HttpHeaders(), apiError.getStatus());

  }

  /**
   * Handles MethodArgumentNotValidException and returns a ResponseEntity with a BAD_REQUEST status,
   * including an ApiError object containing the error details extracted from the field error.
   */
  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<Object> handleValidationExceptions(MethodArgumentNotValidException ex) {
    ApiError apiError = new ApiError(
        LocalDateTime.now(),
        HttpStatus.BAD_REQUEST.value(),
        Objects.requireNonNull(ex.getFieldError()).getDefaultMessage(),
        "Please check your data."
    );
    return new ResponseEntity<>(apiError, HttpStatus.BAD_REQUEST);
  }

  /**
   * Handles UnderAgeException and returns a ResponseEntity with a BAD_REQUEST status, including an
   * ApiError object containing the error message and details.
   */
  @ResponseStatus(HttpStatus.BAD_REQUEST)
  @ExceptionHandler(UnderAgeException.class)
  public ResponseEntity<Object> handleUnderAgeExceptions(UnderAgeException ex) {
    ApiError apiError = new ApiError(
        LocalDateTime.now(),
        HttpStatus.BAD_REQUEST.value(),
        ex.getMessage(),
        "Please check try again when you are 18 years old."
    );
    return new ResponseEntity<>(apiError, new HttpHeaders(), apiError.getStatus());
  }

  /**
   * Handles DateArgumentException and returns a ResponseEntity with a BAD_REQUEST status, including
   * an ApiError object containing the error message and details.
   */
  @ResponseStatus(HttpStatus.BAD_REQUEST)
  @ExceptionHandler(DateArgumentException.class)
  public ResponseEntity<Object> handleDateArgumentExceptions(DateArgumentException ex) {
    ApiError apiError = new ApiError(
        LocalDateTime.now(),
        HttpStatus.BAD_REQUEST.value(),
        ex.getMessage(),
        "Please check input data"
    );
    return new ResponseEntity<>(apiError, new HttpHeaders(), apiError.getStatus());
  }
}