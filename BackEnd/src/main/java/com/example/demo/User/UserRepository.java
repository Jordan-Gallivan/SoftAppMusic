package com.example.demo.User;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, String> {

    @Query("SELECT i FROM User i WHERE i.username =?1")
    Optional<User> findUserByUsername(String username);
}
