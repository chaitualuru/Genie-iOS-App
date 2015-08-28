package com.vchamakura.genie;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;

import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;

import com.firebase.client.AuthData;
import com.firebase.client.Firebase;
import com.firebase.client.FirebaseError;

public class Login extends Activity {

    Firebase ref;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        ref.setAndroidContext(this);

        ref = new Firebase("https://getgenie.firebaseio.com/");

        /*      Get references to Button and text fields        */
        final ImageButton closeButton = (ImageButton) findViewById(R.id.closeButton);
        final ImageButton loginButton = (ImageButton) findViewById(R.id.loginButton);

        final EditText email = (EditText) findViewById(R.id.email);
        final EditText password = (EditText) findViewById(R.id.password);
        /*      END of getting references       */


        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if ((email.getText().toString().trim().isEmpty()) && (password.getText().toString().trim().isEmpty())) {
                    Log.i("GENIE123", "Enter email and password");
                } else if (password.getText().toString().trim().isEmpty()) {
                    Log.i("GENIE123", "Enter password");
                } else if (email.getText().toString().trim().isEmpty())  {
                    Log.i("GENIE123", "Enter email");
                } else {
                    Log.i("GENIE123", "Entered");
                    ref.authWithPassword(email.getText().toString().trim(), password.getText().toString().trim(),
                            new Firebase.AuthResultHandler() {
                        @Override
                        public void onAuthenticated(AuthData authData) {
                            Intent loginIntent = new Intent(Login.this, Home.class);
                            startActivity(loginIntent);
                        }

                        @Override
                        public void onAuthenticationError(FirebaseError firebaseError) {
                            switch (firebaseError.getCode()) {
                                case FirebaseError.INVALID_EMAIL:
                                    new AlertDialog.Builder(new ContextThemeWrapper(Login.this,
                                            android.R.style.Theme_DeviceDefault_Dialog_Alert))
                                            .setTitle("Error")
                                            .setMessage("The specified email address is invalid.")
                                            .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                                public void onClick(DialogInterface dialog, int which) {
                                                    email.setText("");
                                                }
                                            })
                                            .setIcon(android.R.drawable.ic_dialog_alert)
                                            .create()
                                            .show();
                                    break;
                                case FirebaseError.INVALID_PASSWORD:
                                    new AlertDialog.Builder(new ContextThemeWrapper(Login.this,
                                            android.R.style.Theme_DeviceDefault_Dialog_Alert))
                                            .setTitle("Error")
                                            .setMessage("The specified password is incorrect.")
                                            .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                                public void onClick(DialogInterface dialog, int which) {
                                                    password.setText("");
                                                }
                                            })
                                            .setIcon(android.R.drawable.ic_dialog_alert)
                                            .create()
                                            .show();
                                    break;
                                case FirebaseError.USER_DOES_NOT_EXIST:
                                    new AlertDialog.Builder(new ContextThemeWrapper(Login.this,
                                            android.R.style.Theme_DeviceDefault_Dialog_Alert))
                                            .setTitle("Error")
                                            .setMessage("The specified email address is not registered.")
                                            .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                                public void onClick(DialogInterface dialog, int which) {
                                                    email.setText("");
                                                }
                                            })
                                            .setIcon(android.R.drawable.ic_dialog_alert)
                                            .create()
                                            .show();
                                    break;
                            }
                        }
                    });
                }
            }
        });

        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

    }

}
