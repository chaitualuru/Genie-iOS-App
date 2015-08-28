package com.vchamakura.genie;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;

import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageButton;

import com.firebase.client.AuthData;
import com.firebase.client.Firebase;
import com.firebase.client.FirebaseError;

import java.util.Map;

public class Register extends Activity {

    Firebase ref;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        Firebase.setAndroidContext(this);

        ref = new Firebase("https://getgenie.firebaseio.com/");

        /*      Get References to all the text fields       */
        final EditText phone = (EditText) findViewById(R.id.phone);
        final EditText email = (EditText) findViewById(R.id.email);
        final EditText firstName = (EditText) findViewById(R.id.firstName);
        final EditText lastName = (EditText) findViewById(R.id.lastName);
        final EditText password = (EditText) findViewById(R.id.password);
        /*      End Getting references        */

        final ImageButton closeButton = (ImageButton) findViewById(R.id.closeButton);
        final ImageButton registerButton = (ImageButton) findViewById(R.id.registerButton);

        /*      Close activity when cross button is clicked.        */
        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        /*      End closing activity        */

        registerButton.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {
                /*      Making Register Request to FireBase.        */
                ref.createUser(email.getText().toString(), password.getText().toString(), new Firebase.ValueResultHandler<Map<String, Object>>() {

                    /*      On Successful Registration      */
                    @Override
                    public void onSuccess(Map<String, Object> result) {
                        Log.i("GENIE123", "Successfully created user account.");
                        final String uid = result.get("uid").toString();

                        /*      Logging In the User before Writing Data     */
                        ref.authWithPassword(email.getText().toString(), password.getText().toString(),
                                new Firebase.AuthResultHandler() {

                            /*      On Successful Authentication        */
                            @Override
                            public void onAuthenticated(AuthData authData) {
                                Firebase users = ref.child("users");
                                Firebase user = users.child(uid);
                                user.child("first_name").setValue(firstName.getText().toString());
                                user.child("last_name").setValue(lastName.getText().toString());
                                user.child("email_address").setValue(email.getText().toString());
                                user.child("mobile_number").setValue(phone.getText().toString());
                                Log.i("GENIE123", "Logged in after successfully registering");
                            }
                            /*      END of On Successful Authentication        */

                            @Override
                            public void onAuthenticationError(FirebaseError firebaseError) {
                                Log.e("GENIE123", "Logging in failed after successfully registering");
                            }
                        });
                        /*      END of Logging In the User before Writing Data     */
                    }
                    /*      END of on successful registration       */


                    /*      Error in registering user       */
                    @Override
                    public void onError(FirebaseError firebaseError) {
                        Log.i("GENIE123", firebaseError.getMessage());
                        switch (firebaseError.getCode()) {
                            case FirebaseError.EMAIL_TAKEN:
                                new AlertDialog.Builder(new ContextThemeWrapper(Register.this,
                                        android.R.style.Theme_DeviceDefault_Dialog_Alert))
                                        .setTitle("Error")
                                        .setMessage("The specified email address is already in use.")
                                        .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                            public void onClick(DialogInterface dialog, int which) {
                                                email.setText("");
                                            }
                                        })
                                        .setIcon(android.R.drawable.ic_dialog_alert)
                                        .show();
                                break;
                            case FirebaseError.INVALID_EMAIL:
                                new AlertDialog.Builder(new ContextThemeWrapper(Register.this,
                                        android.R.style.Theme_DeviceDefault_Dialog_Alert))
                                        .setTitle("Error")
                                        .setMessage("The specified email address is invalid.")
                                        .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                            public void onClick(DialogInterface dialog, int which) {
                                                email.setText("");
                                            }
                                        })
                                        .setIcon(android.R.drawable.ic_dialog_alert)
                                        .show();
                                break;
                            default:
                                new AlertDialog.Builder(new ContextThemeWrapper(Register.this,
                                        android.R.style.Theme_DeviceDefault_Dialog_Alert))
                                        .setTitle("Error")
                                        .setMessage("Something went wrong. Please try again.")
                                        .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                            public void onClick(DialogInterface dialog, int which) {
                                               //Do Nothing
                                            }
                                        })
                                        .setIcon(android.R.drawable.ic_dialog_alert)
                                        .show();
                                break;

                        }
                    }
                    /*      END of error in registering user        */

                });
                /*      End making register call to FireBase        */
            }
        });


    }
}
