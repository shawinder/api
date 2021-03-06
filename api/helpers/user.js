const {
  db,
  as,
  USER_BY_EMAIL,
  USER_BY_ID,
  CREATE_USER_ID
} = require("../helpers/db");
const log = require("winston");
const { checkJwtRequired, checkJwtOptional } = require("./checkJwt");
const unless = require("express-unless");

async function preferUser(req, res, next) {
  console.log("preferUser()");
  try {
    checkJwtOptional(req, res, (err, req_, res_, next_) =>
      commonUserHandler(false, err, req, res, next)
    );
  } catch (err) {
    console.error("Error in preferUser: %s", JSON.stringify(err));
  }
}

async function ensureUser(req, res, next) {
  console.log("ensureUser()");
  try {
    checkJwtRequired(req, res, (err, req_, res_, next_) =>
      commonUserHandler(true, err, req, res, next)
    );
  } catch (err) {
    console.error("Error in ensureUser: %s", JSON.stringify(err));
  }
}

async function commonUserHandler(required, err, req, res, next) {
  //  try {
  if (required !== true && require !== false) {
    console.log("is required actually an error? %s", JSON.stringify(required));
  }
  if (err) {
    console.error(
      "%s %s (%s) in commonUserHandler: %s",
      err.status,
      err.name,
      err.code,
      err.message
    );
  }
  let user = req.user;
  const language = as.value(req.params.language || "en");
  if (!user) {
    if (required) {
      return res.status(401).json({
        message: "User must be logged in to perform this function"
      });
    } else {
      // nothing more we can do without a user
      return next();
    }
  }
  if (required && !okToEdit(user)) {
    res.status(401).json({
      message: "User is not authorized to add or edit content."
    });
  }
  let userIdObj = await db.oneOrNone(USER_BY_EMAIL, {
    userEmail: user.email
  });
  // get full user object
  let userObj = null;
  if (userIdObj) {
    userObj = await db.oneOrNone(USER_BY_ID, {
      userId: userIdObj.id,
      language
    });
  }
  if (userObj) {
    req.user = userObj.user;
  } else {
    console.warn("no userObj found for %s", JSON.stringify(req.user));
    let newUser;
    let pictureUrl = user.picture;
    if (user.user_metadata && user.user_metadata.customPic) {
      pictureUrl = user.user_metadata.customPic;
    }
    newUser = await db.one(CREATE_USER_ID, {
      userEmail: user.email,
      // if user.name is null, use first part of email address for username
      userName: user.name || user.email.substr(0, user.email.indexOf("@")),
      joinDate: user.created_at,
      // TODO: fix auth0UserId error
      // this line was throwing an error for auth0UserId being undefined,
      // so changed it to null for now
      // auth0UserId: auth0UserId,
      auth0UserId: null,
      pictureUrl: pictureUrl,
      bio: ""
    });
    req.user.user_id = newUser.user_id;
  }
  next();
  //  } catch (error) {
  //    console.trace("Problem creating user", JSON.stringify(error));
  //    return res.status(500).json({
  //      OK: false,
  //      error: error
  //    });
  //  }
}

function okToEdit(user) {
  // User should be logged in and not be part of the Banned group
  if (
    !(
      user.app_metadata &&
      user.app_metadata.authorization &&
      user.app_metadata.authorization.groups
    )
  ) {
    // how do we have a user, but not this metadata?
    // Because that's the way OAuth is configured, duh. No metatdata
    // means the user cannot be in the Banned group, allow editing.
    return true;
  }
  if (user.app_metadata.authorization.groups.includes("Banned")) {
    return false;
  }
  return true;
}

ensureUser.unless = unless;
preferUser.unless = unless;

module.exports = exports = {
  ensureUser,
  preferUser,
  okToEdit
};
